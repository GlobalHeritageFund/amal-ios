//
//  ViewController.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoSettings.h"
#import "PhotoStorage.h"
#import "AMLMetadata.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CameraViewController ()

@property (nonatomic) AVCaptureDevice *inputDeviceFront;
@property (nonatomic) AVCaptureDevice *inputDeviceBack;

@property (nonatomic) AVCaptureInput *capturingInputFront;
@property (nonatomic) AVCaptureInput *capturingInputBack;

@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic) AVCaptureSession *captureSession;

@property (nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic) CLLocationManager *locationManager;


@property (weak) IBOutlet UIButton *swapButton;
@property (weak) IBOutlet UIButton *flashButton;

@property (weak) IBOutlet UIButton *rapidButton;
@property (weak) IBOutlet UIButton *photoButton;

@property (weak) IBOutlet UIView *imagePreviewOverlay;

@property (weak, nonatomic) IBOutlet UIView *cameraPermissionDialog;

@property (nonatomic) UIImageView *focusSquare;


@end

@implementation CameraViewController

+ (instancetype)makeFromStoryboard {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CameraViewController" bundle:nil];
    id viewController = [storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    return viewController;
}

- (void)loadDevices {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        
        if ([device position] == AVCaptureDevicePositionBack) {
            self.inputDeviceBack = device;
        } else {
            self.inputDeviceFront = device;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    
    PhotoSettings.shared.currentMetadata.latitude = location.coordinate.latitude;
    PhotoSettings.shared.currentMetadata.longitude = location.coordinate.longitude;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.focusSquare = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_focus"]];
    self.focusSquare.hidden = YES;
    [self.focusSquare sizeToFit];
    [self.view addSubview:self.focusSquare];

    self.locationManager = [CLLocationManager new];
    
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    [self loadDevices];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    if (self.inputDeviceBack == nil) {
        return;
    }

    self.captureSession = [AVCaptureSession new];

    [self.captureSession startRunning];

    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    }

    self.torchMode = AVCaptureTorchModeAuto;

    self.capturingInputBack = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDeviceBack error:nil];
    self.capturingInputFront = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDeviceFront error:nil];

    [self.captureSession beginConfiguration];

    if (self.capturingInputBack == nil) {
        //camera access not granted
        return;
    }

    [self.captureSession addInput:self.capturingInputBack];

    [self.captureSession commitConfiguration];

    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];

    self.previewLayer.frame = self.previewImageView.bounds;

    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.previewImageView.layer addSublayer:self.previewLayer];

    self.stillImageOutput = [AVCaptureStillImageOutput new];

    self.stillImageOutput.outputSettings = @{ AVVideoCodecKey:AVVideoCodecJPEG };

    if ([self.captureSession canAddOutput:self.stillImageOutput]) {
        [self.captureSession addOutput:self.stillImageOutput];
    }

    [self beginDetectingVolumeClicks];

    [self hideVolumeBezel];

    [self beginDetectingFocusTaps];

    [self beginDetectingZoom];

}

- (void)hideVolumeBezel {
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectOffset(CGRectZero, -100, -100)];
    [self.view addSubview:volumeView];
}

- (void)beginDetectingVolumeClicks {
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (void)beginDetectingFocusTaps {
    UITapGestureRecognizer *shortTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapToFocus:)];
    [self.previewImageView addGestureRecognizer:shortTap];
    self.previewImageView.userInteractionEnabled = YES;
}

- (void)handleTapToFocus:(UITapGestureRecognizer *)tapGesture {
    AVCaptureDevice *currentDevice = [self currentCaptureDevice];

    if (![currentDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]
        || ![currentDevice isFocusPointOfInterestSupported]) {
        return;
    }

    if (tapGesture.state != UIGestureRecognizerStateEnded) {
        return;
    }

    CGPoint focusPoint = [tapGesture locationInView:self.previewImageView];

    CGFloat focusX = focusPoint.x / self.previewImageView.frame.size.width;
    CGFloat focusY = focusPoint.y / self.previewImageView.frame.size.height;
    CGPoint point = CGPointMake(focusX, focusY);

    self.focusSquare.center = focusPoint;
    self.focusSquare.hidden = NO;

    [self withCameraConfigurationLock:^{
        [currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        [currentDevice setFocusPointOfInterest:point];
    }];

}

- (void)beginDetectingZoom {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoom:)];
    [self.previewImageView addGestureRecognizer:pinch];
    self.previewImageView.userInteractionEnabled = YES;
}

- (void)handleZoom:(UIPinchGestureRecognizer *)pinch {
    CGFloat pinchVelocityDividerFactor = 5.0f;

    if (pinch.state != UIGestureRecognizerStateChanged) {
        return;
    }

    [self withCameraConfigurationLock:^{
        CGFloat desiredZoomFactor = self.currentCaptureDevice.videoZoomFactor + atan2f(pinch.velocity, pinchVelocityDividerFactor);
        self.currentCaptureDevice.videoZoomFactor = MAX(1.0, MIN(desiredZoomFactor, self.currentCaptureDevice.activeFormat.videoMaxZoomFactor));
    }];
}

- (void)withCameraConfigurationLock:(void (^)())block {
    if ([[self currentCaptureDevice] lockForConfiguration:nil]) {
        block();
        [[self currentCaptureDevice] unlockForConfiguration];
    }
}

- (void)volumeChanged:(NSNotification *)note {
    if ([note.userInfo[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"] isEqual: @"ExplicitVolumeChange"]) {
        [self capturePhoto:self];
    }
}

- (void)orientationChange:(NSNotification*)note
{
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;

    [self updateCameraOrientation];

    [UIView animateWithDuration:0.2 animations:^{
        if(orientation == UIDeviceOrientationLandscapeLeft) {
            self.swapButton.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.flashButton.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.rapidButton.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.photoButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        } else if(orientation == UIDeviceOrientationLandscapeRight) {
            self.swapButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.flashButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.rapidButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.photoButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
        } else {
            self.swapButton.transform = CGAffineTransformIdentity;
            self.flashButton.transform = CGAffineTransformIdentity;
            self.rapidButton.transform = CGAffineTransformIdentity;
            self.photoButton.transform = CGAffineTransformIdentity;
        }
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.previewLayer.frame = self.previewImageView.bounds;

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    BOOL cameraPermissionDenied = authStatus == AVAuthorizationStatusDenied;
    self.cameraPermissionDialog.hidden = !cameraPermissionDenied;
    self.photoButton.hidden = cameraPermissionDenied;
    self.flashButton.hidden = cameraPermissionDenied;
    self.swapButton.hidden = cameraPermissionDenied;
}

- (void)updateCameraOrientation {
    AVCaptureVideoOrientation newOrientation;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            newOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            newOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            newOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            newOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            newOrientation = AVCaptureVideoOrientationPortrait;
    }
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = newOrientation;
}

- (IBAction)swapCamera:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    [self.captureSession beginConfiguration];
    
    if(sender.selected) {

        [self.captureSession removeInput:self.capturingInputBack];
        [self.captureSession addInput:self.capturingInputFront];
    }
    else {
        
        [self.captureSession removeInput:self.capturingInputFront];
        [self.captureSession addInput:self.capturingInputBack];
    }
    
    [self.captureSession commitConfiguration];
}

- (AVCaptureDevice *)currentCaptureDevice {
    if (self.swapButton.isSelected) {
        return self.inputDeviceFront;
    } else {
        return self.inputDeviceBack;
    }
}

- (void)setTorchMode:(AVCaptureTorchMode)mode {

    if ([self.inputDeviceBack hasTorch] && [self.inputDeviceBack isTorchModeSupported:mode]) {
        
        if ([self.inputDeviceBack lockForConfiguration:nil]) {
            
            self.inputDeviceBack.torchMode = mode;
            
            [self.inputDeviceBack unlockForConfiguration];
        }
    }
}

- (IBAction)cycleFlash:(UIButton*)sender
{
    if(sender.selected) {
        
        sender.enabled = NO;
        sender.selected = NO;
        
        self.torchMode = AVCaptureTorchModeOff;
    }
    else {
        
        sender.selected = YES;
        
        self.torchMode = AVCaptureTorchModeOn;
    }
}

- (IBAction)setAutoFlash:(id)sender
{
    self.flashButton.enabled = YES;
    self.flashButton.selected = NO;
    
    self.torchMode = AVCaptureTorchModeAuto;
}

- (IBAction)capturePhoto:(id)sender
{
    if(self.stillImageOutput) {
        
        AVCaptureConnection *conn = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:conn completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
            NSData *data = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];

            [[PhotoStorage new] saveJpegLocally:data withMetadata:PhotoSettings.shared.currentMetadata];
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }
    else {
        
        NSData *jpegData = UIImageJPEGRepresentation(self.previewImageView.image, 0.9f);
        
        [[PhotoStorage new] saveJpegLocally:jpegData withMetadata:PhotoSettings.shared.currentMetadata];
    }
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.imagePreviewOverlay.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            self.imagePreviewOverlay.alpha = 0;
        }];
    }];
}

@end
