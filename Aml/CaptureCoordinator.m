//
//  CaptureCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 12/14/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "CaptureCoordinator.h"
#import "CameraViewController.h"

@interface CaptureCoordinator()

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
    UINavigationController *cameraNavigationController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    cameraNavigationController.navigationBarHidden = true;
    cameraNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Camera" image:[UIImage imageNamed:@"ic_camera_outline"] selectedImage:[UIImage imageNamed:@"ic_camera_active"]];
    self.navigationController = cameraNavigationController;

}

@end
