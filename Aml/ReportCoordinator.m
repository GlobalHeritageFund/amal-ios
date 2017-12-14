//
//  ReportCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 12/14/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportCoordinator.h"
#import "ReportsViewController.h"
#import "ReportDetailViewController.h"
#import "ReportCreationCoordinator.h"
#import "LocalDraftDataSource.h"
#import "FirebaseReportDataSource.h"
#import "ReportViewModel.h"
#import "Firebase.h"
#import "ReportDraft.h"
#import "Report.h"
#import "ImageDetailViewController.h"

@interface ReportCoordinator() <ReportsViewControllerDelegate, ReportDetailViewControllerDelegate>

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) NSMutableArray *childCoordinators;

@end

@implementation ReportCoordinator

- (NSMutableArray *)childCoordinators {
    if (!_childCoordinators) {
        self.childCoordinators = [NSMutableArray array];
    }
    return _childCoordinators;
}

- (void)start {

    ReportsViewController *reportsViewController = [[ReportsViewController alloc] init];
    reportsViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:reportsViewController];
    reportsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Reports" image:[UIImage imageNamed:@"ic_folder_shared_outline"] selectedImage:[UIImage imageNamed:@"ic_sync_active"]];
    self.navigationController = navigationController;

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
