//
//  ReportCreationCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 8/12/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportCreationCoordinator.h"
#import "GalleryViewController.h"
#import "ReportDetailViewController.h"
#import "CaptureNotesViewController.h"
#import "LocalPhoto.h"
#import "ReportDraft.h"
#import "ReportUpload.h"
#import "Firebase.h"
#import "LocalDraftDataSource.h"

@interface ReportCreationCoordinator () <GalleryViewControllerDelegate, ReportDetailViewControllerDelegate>

@property (nonatomic) ReportDraft *currentReport;

@end

@implementation ReportCreationCoordinator

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (!self) return nil;

    _viewController = viewController;

    return self;
}

- (instancetype)initWithViewController:(UIViewController *)viewController reportDraft:(ReportDraft *)reportDraft {
    self = [super init];
    if (!self) return nil;

    _viewController = viewController;
    _currentReport = reportDraft;

    return self;
}

- (void)start {
    if (!self.currentReport) {
        GalleryViewController *gallery = [[GalleryViewController alloc] init];
        [gallery loadViewIfNeeded];
        gallery.mode = GalleryModeCreateReport;
        gallery.delegate = self;
        UINavigationController *galleryNavigationController = [[UINavigationController alloc] initWithRootViewController:gallery];
        [self.viewController presentViewController:galleryNavigationController animated:true completion:nil];
    } else {
        ReportDetailViewController *reportDetail = [[ReportDetailViewController alloc] initWithReportDraft:self.currentReport];
        reportDetail.delegate = self;
        UINavigationController *reportDetailNavigationController = [[UINavigationController alloc] initWithRootViewController:reportDetail];
        [self.viewController presentViewController:reportDetailNavigationController animated:true completion:nil];
    }
}

- (void)galleryViewControllerDidTapImport:(GalleryViewController *)galleryViewController {
    //not implemented
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController savePhotos:(NSArray<LocalPhoto *> *)photos {
    //not implemented
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController deletePhotos:(NSArray<LocalPhoto *> *)photos {
    //not implemented
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController createReportWithPhotos:(NSArray<LocalPhoto *> *)photos {
    [FIRAnalytics logEventWithName:@"report_images_selected" parameters:nil];
    self.currentReport = [[ReportDraft alloc] initWithPhotos:photos];
    ReportDetailViewController *reportDetail = [[ReportDetailViewController alloc] initWithReportDraft:self.currentReport];
    reportDetail.delegate = self;
    [galleryViewController.navigationController pushViewController:reportDetail animated:YES];
}

- (void)galleryViewControllerShouldDismiss:(GalleryViewController *)galleryViewController {
    [galleryViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController didTapPhoto:(LocalPhoto *)photo {
    [self.currentReport addPhoto:photo];
    //update upload button state
    //    [self.createReportViewController updateUploadButtonState];
    [galleryViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didTapUploadWithDraft:(ReportDraft *)draft {

    [FIRAnalytics logEventWithName:@"report_upload_tapped" parameters:nil];

    ReportUpload *upload = [[ReportUpload alloc] initWithReportDraft:draft];
    reportDetailViewController.viewModel = [[ReportViewModel alloc] initWithReport:upload];

    [upload upload];
    [[upload.promise then:^id _Nullable(id  _Nonnull object) {
        [FIRAnalytics logEventWithName:@"report_upload_completed" parameters:nil];

        reportDetailViewController.viewModel = [[ReportViewModel alloc] initWithReport:object];
        reportDetailViewController.navigationItem.hidesBackButton = YES;
        reportDetailViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleDone target:self action:@selector(dismissReportCreation:)];
        reportDetailViewController.navigationItem.leftBarButtonItem = nil;

        [[LocalDraftDataSource new] removeReportDraft:draft];
        
        return nil;
    }] catch:^(NSError * _Nonnull error) {
        [FIRAnalytics logEventWithName:@"report_upload_failed" parameters:nil];

        reportDetailViewController.viewModel = [[ReportViewModel alloc] initWithReport:draft];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"An error occurred" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [reportDetailViewController presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)reportDetailViewControllerDidTapCancel:(ReportDetailViewController *)reportDetailViewController {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Save?" message:@"Would you like to save this as a draft?" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Save Draft" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[LocalDraftDataSource new] addReportDraft:reportDetailViewController.viewModel.draft];
        [reportDetailViewController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleCancel handler:nil]];
    [reportDetailViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didSelectPhoto:(LocalPhoto *)photo {
    CaptureNotesViewController *captureNotes = [[CaptureNotesViewController alloc] initWithPhoto:photo];
    [reportDetailViewController.navigationController pushViewController:captureNotes animated:YES];
}

- (void)reportDetailViewControllerDidTapAddPhoto:(ReportDetailViewController *)reportDetailViewController {
    GalleryViewController *galleryViewController = [[GalleryViewController alloc] init];
    [galleryViewController loadViewIfNeeded];
    UINavigationController *galleryNavigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    galleryViewController.mode = GalleryModeSingleSelect;
    galleryViewController.delegate = self;
    [reportDetailViewController presentViewController:galleryNavigationController animated:true completion:nil];
}

- (void)dismissReportCreation:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
