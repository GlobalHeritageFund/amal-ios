//
//  CaptureCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 12/14/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "CaptureCoordinator.h"
#import "CameraViewController.h"
#import "SettingsViewController.h"
#import "PassphraseViewController.h"
#import "AcknowledgementsViewController.h"

@interface CaptureCoordinator() <CameraViewControllerDelegate, UINavigationControllerDelegate, SettingsViewControllerDelegate>

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) NSMutableArray *childCoordinators;

@end

@implementation CaptureCoordinator

- (NSMutableArray *)childCoordinators {
    if (!_childCoordinators) {
        self.childCoordinators = [NSMutableArray array];
    }
    return _childCoordinators;
}

- (void)start {
    CameraViewController *cameraViewController = [CameraViewController makeFromStoryboard];
    cameraViewController.delegate = self;
    UINavigationController *cameraNavigationController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    cameraNavigationController.navigationBarHidden = true;
    cameraNavigationController.delegate = self;
    cameraNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Camera", @"A tab bar button label that takes you to the Camera tab.") image:[UIImage imageNamed:@"ic_camera"] selectedImage:[UIImage imageNamed:@"ic_camera"]];
    self.navigationController = cameraNavigationController;

}

- (void)settingsButtonTappedOnCameraViewController:(CameraViewController *)cameraViewController {
    SettingsViewController *settings = [[SettingsViewController alloc] initWithDelegate:self];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController pushViewController:settings animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[CameraViewController class]]) {
        [navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark SettingsViewControllerDelegate

- (void)didSelectEnterPassphrase {
    [self.navigationController pushViewController:[[PassphraseViewController alloc] init] animated:YES];
}

- (void)didSelectAcknowledgements {
    [self.navigationController pushViewController:[[AcknowledgementsViewController alloc] init] animated:YES];
}

@end
