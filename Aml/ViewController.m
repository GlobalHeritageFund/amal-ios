//
//  ViewController.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (weak) IBOutlet UIButton *swapButton;
@property (weak) IBOutlet UIButton *flashButton;

@property (weak) IBOutlet UIView *imagePreviewOverlay;

@end

@implementation ViewController {
    AVCaptureDevice *inputDeviceFront;
    AVCaptureDevice *inputDeviceBack;
    
    AVCaptureInput *capturingInputFront;
    AVCaptureInput *capturingInputBack;
    
    AVCaptureSession *captureSession;
    
    AVCaptureVideoPreviewLayer *previewLayer;
}

- (void)loadDevices
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in devices) {
        
        if ([device position] == AVCaptureDevicePositionBack)
            
            inputDeviceBack = device;
        else
            inputDeviceFront = device;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    captureSession = [AVCaptureSession new];
    
    [captureSession startRunning];
    
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    [self loadDevices];
    
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
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        self.imagePreviewOverlay.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            self.imagePreviewOverlay.alpha = 0;
        }];
    }];
}

@end
