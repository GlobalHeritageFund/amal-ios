//
//  AppCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "AppCoordinator.h"
#import "UIColor+Additions.h"
#import "CameraViewController.h"
#import "GalleryViewController.h"
#import "ReportsViewController.h"
#import "TabBarPage.h"
#import "FirstLaunch.h"
#import "CaptureNotesViewController.h"
#import "LocalPhoto.h"
#import "ReportDetailViewController.h"
#import "ReportDraft.h"
#import "ReportCreationCoordinator.h"
#import "ReportUpload.h"
#import <Photos/Photos.h>
#import "AMLMetadata.h"
#import "PhotoStorage.h"
#import "NSObject+Helpers.h"
#import "QBImagePickerController.h"
#import "Report.h"
#import "Firebase.h"

@interface AppCoordinator () <GalleryViewControllerDelegate, ReportsViewControllerDelegate, QBImagePickerControllerDelegate>

@property (nonatomic) FirstLaunch *firstLaunch;
@property (nonatomic) NSMutableArray *childCoordinators;

@end

@implementation AppCoordinator

- (instancetype)initWithWindow:(UIWindow *)window {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.window = window;
    return self;
}

- (NSMutableArray *)childCoordinators {
    if (!_childCoordinators) {
        self.childCoordinators = [NSMutableArray array];
    }
    return _childCoordinators;
}

- (FirstLaunch *)firstLaunch {
    if (!_firstLaunch) {
        _firstLaunch = [FirstLaunch new];
    }
    return _firstLaunch;
}

- (void)start {
    UITabBarController *tabBarController = [[TabBarPage alloc] init];

    GalleryViewController *galleryViewController = [[GalleryViewController alloc] init];
    galleryViewController.delegate = self;
    UINavigationController *galleryNavigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    galleryViewController.delegate = self;
    galleryNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Gallery" image:[UIImage imageNamed:@"ic_assess_outline"] selectedImage:[UIImage imageNamed:@"ic_assess_active"]];

    CameraViewController *cameraViewController = [CameraViewController makeFromStoryboard];
    UINavigationController *cameraNavigationController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    cameraNavigationController.navigationBarHidden = true;
    cameraNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Camera" image:[UIImage imageNamed:@"ic_camera_outline"] selectedImage:[UIImage imageNamed:@"ic_camera_active"]];


    ReportsViewController *reportsViewController = [[ReportsViewController alloc] init];
    reportsViewController.delegate = self;
    UINavigationController *reportsNavigationController = [[UINavigationController alloc] initWithRootViewController:reportsViewController];
    reportsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Reports" image:[UIImage imageNamed:@"ic_folder_shared_outline"] selectedImage:[UIImage imageNamed:@"ic_sync_active"]];


    tabBarController.viewControllers = @[
                                         galleryNavigationController,
                                         cameraNavigationController,
                                         reportsNavigationController,
                                         ];
    tabBarController.selectedIndex = 1;
    self.window.tintColor = [UIColor amalTeal];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];

    if (self.firstLaunch.isFirstLaunch) {
        UIViewController *page = [[UIStoryboard storyboardWithName:@"Intro" bundle:nil] instantiateInitialViewController];

        [self.window.rootViewController presentViewController:page animated:YES completion:nil];

        [self.firstLaunch launched];
    }
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController didTapPhoto:(LocalPhoto *)photo {
    CaptureNotesViewController *captureNotes = [[CaptureNotesViewController alloc] initWithPhoto:photo];
    [galleryViewController.navigationController pushViewController:captureNotes animated:YES];
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController createReportWithPhotos:(NSArray<LocalPhoto *> *)photos {

    [FIRAnalytics logEventWithName:@"multi_create_report" parameters:@{ @"count": @(photos.count) }];
    galleryViewController.mode = GalleryModeNormal;

    ReportDraft *report = [[ReportDraft alloc] initWithPhotos:photos];

    ReportCreationCoordinator *reportCreation = [[ReportCreationCoordinator alloc] initWithViewController:galleryViewController reportDraft:report];
    [reportCreation start];
    [self.childCoordinators addObject:reportCreation];
}

- (void)galleryViewControllerShouldDismiss:(GalleryViewController *)galleryViewController {
    [galleryViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)galleryViewControllerDidTapImport:(GalleryViewController *)galleryViewController {

    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 50;
    imagePickerController.showsNumberOfSelectedAssets = YES;

    [self.window.rootViewController presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)qb_imagePickerController:(QBImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets {

    [FIRAnalytics logEventWithName:@"imported_images" parameters:@{ @"count": @(assets.count) }];

    for (PHAsset *asset in assets) {
        [self importAsset:asset];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)importAsset:(PHAsset *)asset {
    [PHImageManager.defaultManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

        if(!imageData)
            return;

        AMLMetadata *metadata = [AMLMetadata new];

        metadata.latitude = asset.location.coordinate.latitude;
        metadata.longitude = asset.location.coordinate.longitude;
        metadata.date = asset.creationDate;
        metadata.localIdentifier = asset.localIdentifier;

        if ([[[PhotoStorage new] fetchPhotos] indexOfObjectPassingTest:^BOOL(LocalPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { return [obj.metadata.localIdentifier isEqualToString:metadata.localIdentifier]; }] != NSNotFound) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Duplicate found" message:@"This photo has already been imported. This won't other photos you're importing." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            return;
        }

        [[PhotoStorage new] saveJpegLocally:imageData withMetadata:metadata];

        [[[[[[[self.window.rootViewController asClassOrNil:[UITabBarController class]] viewControllers] objectAtIndex:0] asClassOrNil:[UINavigationController class]] topViewController] asClassOrNil:[GalleryViewController class]] reloadData];

    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)reportsViewControllerDidTapCompose:(ReportsViewController *)reportsViewController {
    ReportCreationCoordinator *reportCreation = [[ReportCreationCoordinator alloc] initWithViewController:reportsViewController];
    [reportCreation start];
    [self.childCoordinators addObject:reportCreation];
}

- (void)reportsViewController:(ReportsViewController *)reportsViewController didTapReport:(Report *)report {
    [FIRAnalytics logEventWithName:@"report_tapped" parameters:nil];

    ReportViewModel *viewModel = [[ReportViewModel alloc] initWithReport:report];
    ReportDetailViewController *reportViewController = [[ReportDetailViewController alloc] initWithReportViewModel:viewModel];
    [reportsViewController.navigationController pushViewController:reportViewController animated:YES];
    [reportViewController loadViewIfNeeded];
    reportViewController.navigationItem.leftBarButtonItem = nil;
}

@end
