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
#import "AssessViewController.h"
#import "LocalPhoto.h"
#import "ReportDraft.h"
#import "ReportUpload.h"
#import "Firebase.h"
#import "LocalDraftDataSource.h"
#import "Report.h"
#import "ImageDetailViewController.h"

@interface ReportCreationCoordinator () <GalleryViewControllerDelegate, ReportDetailViewControllerDelegate, AssessViewControllerDelegate>

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

- (void)assessViewControllerDidTapEditCoordinates:(AssessViewController *)assessViewController {
    NSLog(@"show map editing vc");
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Would you like to save this as a draft?" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [reportDetailViewController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Save Draft" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[LocalDraftDataSource new] addReportDraft:reportDetailViewController.viewModel.draft];
        [reportDetailViewController dismissViewControllerAnimated:YES completion:nil];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }]];
    [reportDetailViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didSelectLocalPhoto:(LocalPhoto *)photo {
    AssessViewController *assess = [[AssessViewController alloc] initWithPhoto:photo];
    assess.delegate = self;
    [reportDetailViewController.navigationController pushViewController:assess animated:YES];
}

- (void)reportDetailViewControllerDidTapAddPhoto:(ReportDetailViewController *)reportDetailViewController {
    GalleryViewController *galleryViewController = [[GalleryViewController alloc] init];
    [galleryViewController loadViewIfNeeded];
    UINavigationController *galleryNavigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    galleryViewController.mode = GalleryModeSingleSelect;
    galleryViewController.delegate = self;
    [reportDetailViewController presentViewController:galleryNavigationController animated:true completion:nil];
}

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didSelectRemotePhoto:(RemotePhoto *)photo {
    ImageDetailViewController *imageDetail = [[ImageDetailViewController alloc] init];
    [[photo loadFullSizeImage] then:^id _Nullable(id  _Nonnull object) {
        imageDetail.imageView.image = object;
        return nil;
    }];
    [reportDetailViewController.navigationController pushViewController:imageDetail animated:YES];
}


- (void)dismissReportCreation:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
