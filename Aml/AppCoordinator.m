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
#import "CreateReportViewController.h"
#import "ReportDraft.h"
#import "ReportCreationCoordinator.h"
#import "ReportUpload.h"

@interface AppCoordinator () <GalleryViewControllerDelegate, ReportsViewControllerDelegate, CreateReportViewControllerDelegate>

@property (nonatomic) FirstLaunch *firstLaunch;
@property (nonatomic) NSMutableArray *childCoordinators;

@property (nonatomic) CreateReportViewController *createReportViewController;


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

    CameraViewController *cameraViewController = [CameraViewController makeFromStoryboard];
    UINavigationController *cameraNavigationController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    cameraNavigationController.navigationBarHidden = true;
    cameraNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Camera" image:[UIImage imageNamed:@"ic_camera_outline"] selectedImage:[UIImage imageNamed:@"ic_camera_active"]];

    GalleryViewController *galleryViewController = [[GalleryViewController alloc] init];
    galleryViewController.delegate = self;
    UINavigationController *galleryNavigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    galleryViewController.delegate = self;
    galleryNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Gallery" image:[UIImage imageNamed:@"ic_assess_outline"] selectedImage:[UIImage imageNamed:@"ic_assess_active"]];

    ReportsViewController *reportsViewController = [[ReportsViewController alloc] init];
    reportsViewController.delegate = self;
    UINavigationController *reportsNavigationController = [[UINavigationController alloc] initWithRootViewController:reportsViewController];
    reportsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Reports" image:[UIImage imageNamed:@"ic_folder_shared_outline"] selectedImage:[UIImage imageNamed:@"ic_sync_active"]];


    tabBarController.viewControllers = @[
                                         cameraNavigationController,
                                         galleryNavigationController,
                                         reportsNavigationController,
                                         ];
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
    if (galleryViewController.mode == GalleryModeSingleSelect) {
        [self.createReportViewController.reportDraft addPhoto:photo];
        [self.createReportViewController.tableView reloadData];
        [self.createReportViewController updateUploadButtonState];
        [galleryViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        CaptureNotesViewController *captureNotes = [[CaptureNotesViewController alloc] initWithPhoto:photo];
        [galleryViewController.navigationController pushViewController:captureNotes animated:YES];
    }
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController createReportWithPhotos:(NSArray<LocalPhoto *> *)photos {
    ReportDraft *report = [[ReportDraft alloc] initWithPhotos:photos];
    CreateReportViewController *createReport = [[CreateReportViewController alloc] initWithReportDraft:report];
    createReport.delegate = self;
    [galleryViewController.navigationController pushViewController:createReport animated:YES];
    galleryViewController.mode = GalleryModeNormal;
    self.createReportViewController = createReport;
}

- (void)galleryViewControllerShouldDismiss:(GalleryViewController *)galleryViewController {
    [galleryViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)reportsViewControllerDidTapCompose:(ReportsViewController *)reportsViewController {
    ReportCreationCoordinator *reportCreation = [[ReportCreationCoordinator alloc] initWithViewController:reportsViewController];
    [reportCreation start];
    [self.childCoordinators addObject:reportCreation];
}

- (void)createReportViewController:(CreateReportViewController *)createReportViewController didTapUploadWithDraft:(ReportDraft *)draft {
    createReportViewController.title = @"Uploading...";
    createReportViewController.uploadButton.enabled = NO;

    ReportUpload *upload = [[ReportUpload alloc] initWithReportDraft:draft];
    createReportViewController.upload = upload;
    
    [upload upload];
    [[upload.promise then:^id _Nullable(id  _Nonnull object) {
        createReportViewController.title = @"Uploaded!";
        return nil;
    }] catch:^(NSError * _Nonnull error) {
        //probably should reset state to not uploaded
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"An error occurred" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [createReportViewController presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)createReportViewController:(CreateReportViewController *)createReportViewController didSelectPhoto:(LocalPhoto *)photo {
    CaptureNotesViewController *captureNotes = [[CaptureNotesViewController alloc] initWithPhoto:photo];
    [createReportViewController.navigationController pushViewController:captureNotes animated:YES];
}

- (void)createReportViewControllerDidTapAddPhoto:(CreateReportViewController *)createReportViewController {
    GalleryViewController *galleryViewController = [[GalleryViewController alloc] init];
    [galleryViewController loadViewIfNeeded];
    UINavigationController *galleryNavigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    galleryViewController.mode = GalleryModeSingleSelect;
    galleryViewController.delegate = self;
    [createReportViewController presentViewController:galleryNavigationController animated:true completion:nil];
}

@end
