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

@property (weak) IBOutlet UIButton *swapButton;
@property (weak) IBOutlet UIButton *flashButton;

@property (weak) IBOutlet UIButton *rapidButton;
@property (weak) IBOutlet UIButton *photoButton;

@property (weak) IBOutlet UIView *imagePreviewOverlay;

@property (weak, nonatomic) IBOutlet UIView *cameraPermissionDialog;

@end

@implementation CameraViewController {
    AVCaptureDevice *inputDeviceFront;
    AVCaptureDevice *inputDeviceBack;
    
    AVCaptureInput *capturingInputFront;
    AVCaptureInput *capturingInputBack;
    
    AVCaptureStillImageOutput *stillImageOutput;
    
    AVCaptureSession *captureSession;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    
    CLLocationManager *locationManager;
}

+ (instancetype)makeFromStoryboard {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CameraViewController" bundle:nil];
    id viewController = [storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    return viewController;
}

- (void)loadDevices {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        
        if ([device position] == AVCaptureDevicePositionBack) {
            inputDeviceBack = device;
        } else {
            inputDeviceFront = device;
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

    locationManager = [CLLocationManager new];
    
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    [self loadDevices];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    if (inputDeviceBack == nil) {
        return;
    }

    captureSession = [AVCaptureSession new];

    [captureSession startRunning];

    if ([captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    }

    self.torchMode = AVCaptureTorchModeAuto;

    capturingInputBack = [AVCaptureDeviceInput deviceInputWithDevice:inputDeviceBack error:nil];
    capturingInputFront = [AVCaptureDeviceInput deviceInputWithDevice:inputDeviceFront error:nil];

    [captureSession beginConfiguration];

    if (capturingInputBack == nil) {
        //camera access not granted
        return;
    }

    [captureSession addInput:capturingInputBack];

    [captureSession commitConfiguration];

    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];

    previewLayer.frame = self.previewImageView.bounds;

    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.previewImageView.layer addSublayer:previewLayer];

    stillImageOutput = [AVCaptureStillImageOutput new];

    stillImageOutput.outputSettings = @{ AVVideoCodecKey:AVVideoCodecJPEG };

    if ([captureSession canAddOutput:stillImageOutput]) {
        [captureSession addOutput:stillImageOutput];
    }

    [self beginDetectingVolumeClicks];

    [self hideVolumeBezel];

    [self beginDetectingFocusTaps];

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

    [self withCameraConfigurationLock:^{
        [currentDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        [currentDevice setFocusPointOfInterest:point];
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
    
    previewLayer.frame = self.previewImageView.bounds;

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
    AVCaptureConnection *connection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = newOrientation;
}

- (IBAction)swapCamera:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    [captureSession beginConfiguration];
    
    if(sender.selected) {

        [captureSession removeInput:capturingInputBack];
        [captureSession addInput:capturingInputFront];
    }
    else {
        
        [captureSession removeInput:capturingInputFront];
        [captureSession addInput:capturingInputBack];
    }
    
    [captureSession commitConfiguration];
}

- (AVCaptureDevice *)currentCaptureDevice {
    if (self.swapButton.isSelected) {
        return inputDeviceFront;
    } else {
        return inputDeviceBack;
    }
}

- (void)setTorchMode:(AVCaptureTorchMode)mode {

    if ([inputDeviceBack hasTorch] && [inputDeviceBack isTorchModeSupported:mode]) {
        
        if ([inputDeviceBack lockForConfiguration:nil]) {
            
            inputDeviceBack.torchMode = mode;
            
            [inputDeviceBack unlockForConfiguration];
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
    if(stillImageOutput) {
        
        AVCaptureConnection *conn = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:conn completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            
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
