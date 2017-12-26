//
//  ViewController.h
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class CameraViewController;

@protocol CameraViewControllerDelegate

- (void)settingsButtonTappedOnCameraViewController:(CameraViewController *)cameraViewController;

@end

@interface CameraViewController : UIViewController<CLLocationManagerDelegate>

+ (instancetype)makeFromStoryboard;

@property (weak) id<CameraViewControllerDelegate> delegate;
@property (weak) IBOutlet UIImageView *previewImageView;

@end

