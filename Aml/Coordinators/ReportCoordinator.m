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
#import "FirebaseReport.h"
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
    reportsViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"header.reports", @"A tab bar button label that takes you to the Reports tab.") image:[UIImage imageNamed:@"ic_report"] selectedImage:[UIImage imageNamed:@"ic_report"]];
    self.navigationController = navigationController;

}

- (void)reportsViewControllerDidTapCompose:(ReportsViewController *)reportsViewController {
    ReportCreationCoordinator *reportCreation = [[ReportCreationCoordinator alloc] initWithViewController:reportsViewController];
    [reportCreation start];
    [self.childCoordinators addObject:reportCreation];
}

- (void)reportsViewController:(ReportsViewController *)reportsViewController didTapReport:(FirebaseReport *)report {
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

    ReportCreationCoordinator *reportCreation = [[ReportCreationCoordinator alloc] initWithViewController:self.navigationController reportDraft:reportDraft];
    [reportCreation start];
    [self.childCoordinators addObject:reportCreation];
}

- (void)reportsViewController:(ReportsViewController *)reportsViewController shouldDeleteDraft:(ReportDraft *)reportDraft atIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"header.are-you-sure", @"A title for a warning asking if the user is sure they want to delete a draft report.") message:NSLocalizedString(@"warning.delete-draft", @"A warning for users asking if they are sure if they want to delete a draft.") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.delete", @"A standard delete button.") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[LocalDraftDataSource new] removeReportDraft:reportDraft];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", @"A standard cancel button.") style:UIAlertActionStyleCancel handler:nil]];
    [reportsViewController presentViewController:alertController animated:true completion:nil];
}

- (void)reportsViewController:(ReportsViewController *)reportsViewController shouldDeleteReport:(FirebaseReport *)report atIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"header.are-you-sure", @"A title for a warning asking if the user is sure they want to delete a report.") message:NSLocalizedString(@"warning.delete-report", @"A warning for users asking if they are sure if they want to delete a report.") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.delete", @"A standard delete button.") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [reportsViewController.publishedReports deleteReport:report];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", @"A standard cancel button.") style:UIAlertActionStyleCancel handler:nil]];
    [reportsViewController presentViewController:alertController animated:true completion:nil];
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

- (void)reportDetailViewControllerDidTapDatabasePicker:(ReportDetailViewController *)reportDetailViewController {
    // not needed
}

@end
