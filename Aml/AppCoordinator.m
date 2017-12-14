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
#import "LocalDraftDataSource.h"
#import "ImageDetailViewController.h"
#import "FirebaseReportDataSource.h"
#import "LocalDraftDataSource.h"
#import "AssessCoordinator.h"

@interface AppCoordinator () <ReportsViewControllerDelegate, ReportDetailViewControllerDelegate>

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
    TabBarPage *tabBarController = [TabBarPage new];

    AssessCoordinator *assessCoordinator = [[AssessCoordinator alloc] init];
    [assessCoordinator start];


    [self.childCoordinators addObject:assessCoordinator];


    CameraViewController *cameraViewController = [CameraViewController makeFromStoryboard];
    UINavigationController *cameraNavigationController = [[UINavigationController alloc] initWithRootViewController:cameraViewController];
    cameraNavigationController.navigationBarHidden = true;
    cameraNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Camera" image:[UIImage imageNamed:@"ic_camera_outline"] selectedImage:[UIImage imageNamed:@"ic_camera_active"]];


    ReportsViewController *reportsViewController = [[ReportsViewController alloc] init];
    reportsViewController.delegate = self;
    UINavigationController *reportsNavigationController = [[UINavigationController alloc] initWithRootViewController:reportsViewController];
    reportsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Reports" image:[UIImage imageNamed:@"ic_folder_shared_outline"] selectedImage:[UIImage imageNamed:@"ic_sync_active"]];


    tabBarController.viewControllers = @[
                                         assessCoordinator.navigationController,
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

- (void)reportsViewControllerDidTapCompose:(ReportsViewController *)reportsViewController {
    ReportCreationCoordinator *reportCreation = [[ReportCreationCoordinator alloc] initWithViewController:reportsViewController];
    [reportCreation start];
    [self.childCoordinators addObject:reportCreation];
}

- (void)reportsViewController:(ReportsViewController *)reportsViewController didTapReport:(Report *)report {
    [FIRAnalytics logEventWithName:@"report_tapped" parameters:nil];

    ReportViewModel *viewModel = [[ReportViewModel alloc] initWithReport:report];
    ReportDetailViewController *reportViewController = [[ReportDetailViewController alloc] initWithReportViewModel:viewModel];
    reportViewController.delegate = self;
    [reportsViewController.navigationController pushViewController:reportViewController animated:YES];
    [reportViewController loadViewIfNeeded];
    reportViewController.navigationItem.leftBarButtonItem = nil;
}

- (void)reportsViewController:(ReportsViewController *)reportsViewController didTapDraft:(ReportDraft *)reportDraft {
    [FIRAnalytics logEventWithName:@"draft_tapped" parameters:nil];

    ReportViewModel *viewModel = [[ReportViewModel alloc] initWithReport:reportDraft];
    ReportDetailViewController *reportViewController = [[ReportDetailViewController alloc] initWithReportViewModel:viewModel];
    [reportsViewController.navigationController pushViewController:reportViewController animated:YES];
    [reportViewController loadViewIfNeeded];
    reportViewController.navigationItem.leftBarButtonItem = nil;
}

- (void)reportsViewController:(ReportsViewController *)reportsViewController shouldDeleteDraft:(ReportDraft *)reportDraft atIndexPath:(NSIndexPath *)indexPath {
    [[LocalDraftDataSource new] removeReportDraft:reportDraft];
}

- (void)reportsViewController:(ReportsViewController *)reportsViewController shouldDeleteReport:(Report *)report atIndexPath:(NSIndexPath *)indexPath {
    [reportsViewController.publishedReports deleteReport:report];
}

- (void)reportDetailViewControllerDidTapCancel:(ReportDetailViewController *)reportDetailViewController {
    //not needed
}

- (void)reportDetailViewControllerDidTapAddPhoto:(ReportDetailViewController *)reportDetailViewController {
    //not needed
}

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didSelectLocalPhoto:(LocalPhoto *)photo {
    //not needed
}

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didTapUploadWithDraft:(ReportDraft *)draft {
    // not needed
}

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didSelectRemotePhoto:(RemotePhoto *)photo {
    ImageDetailViewController *imageDetail = [[ImageDetailViewController alloc] init];
    [[photo loadFullSizeImage] then:^id _Nullable(id  _Nonnull object) {
        imageDetail.imageView.image = object;
        return nil;
    }];
    [reportDetailViewController.navigationController pushViewController:imageDetail animated:YES];
}


@end
