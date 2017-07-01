//
//  ViewController.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PhotoSettings.h"
#import "PhotoStorage.h"
#import "AMLMetadata.h"

@interface CameraViewController ()

@property (weak) IBOutlet UIButton *swapButton;
@property (weak) IBOutlet UIButton *flashButton;

@property (weak) IBOutlet UIButton *rapidButton;
@property (weak) IBOutlet UIButton *photoButton;

@property (weak) IBOutlet UIView *imagePreviewOverlay;

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
    
    if(inputDeviceBack) {
        
        captureSession = [AVCaptureSession new];
        
        [captureSession startRunning];
        
        if([captureSession canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
            captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        }
        
        self.torchMode = AVCaptureTorchModeAuto;
        
        capturingInputBack = [AVCaptureDeviceInput deviceInputWithDevice:inputDeviceBack error:nil];
        capturingInputFront = [AVCaptureDeviceInput deviceInputWithDevice:inputDeviceFront error:nil];
        
        [captureSession beginConfiguration];
        
        [captureSession addInput:capturingInputBack];
        
        [captureSession commitConfiguration];
        
        previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
        
        previewLayer.frame = self.previewImageView.bounds;
        
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        
        [self.previewImageView.layer addSublayer:previewLayer];
        
        stillImageOutput = [AVCaptureStillImageOutput new];
        
        stillImageOutput.outputSettings = @{ AVVideoCodecKey:AVVideoCodecJPEG };
        
        if([captureSession canAddOutput:stillImageOutput])
            [captureSession addOutput:stillImageOutput];
    }
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(orientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
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

- (IBAction)swapCamera:(UIButton*)sender
{
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

- (void)setTorchMode:(AVCaptureTorchMode)mode
{
    if([inputDeviceBack hasTorch] && [inputDeviceBack isTorchModeSupported:mode]) {
        
        if([inputDeviceBack lockForConfiguration:nil]) {
            
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
