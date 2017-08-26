//
//  ReportCreationCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 8/12/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportCreationCoordinator.h"
#import "GalleryViewController.h"
#import "CreateReportViewController.h"
#import "CaptureNotesViewController.h"
#import "LocalPhoto.h"
#import "ReportDraft.h"
#import "ReportUpload.h"

@interface ReportCreationCoordinator () <GalleryViewControllerDelegate, CreateReportViewControllerDelegate>

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
        CreateReportViewController *createReport = [[CreateReportViewController alloc] initWithReportDraft:self.currentReport];
        createReport.delegate = self;
        UINavigationController *createReportNavigationController = [[UINavigationController alloc] initWithRootViewController:createReport];
        [self.viewController presentViewController:createReportNavigationController animated:true completion:nil];
    }
}

- (void)galleryViewControllerDidTapImport:(GalleryViewController *)galleryViewController {
    //not implemented
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController createReportWithPhotos:(NSArray<LocalPhoto *> *)photos {
    self.currentReport = [[ReportDraft alloc] initWithPhotos:photos];
    CreateReportViewController *createReport = [[CreateReportViewController alloc] initWithReportDraft:self.currentReport];
    createReport.delegate = self;
    [galleryViewController.navigationController pushViewController:createReport animated:YES];
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

- (void)createReportViewController:(CreateReportViewController *)createReportViewController didTapUploadWithDraft:(ReportDraft *)draft {

    ReportUpload *upload = [[ReportUpload alloc] initWithReportDraft:draft];
    createReportViewController.viewModel = [[ReportViewModel alloc] initWithReport:upload];

    [upload upload];
    [[upload.promise then:^id _Nullable(id  _Nonnull object) {
        createReportViewController.navigationItem.hidesBackButton = YES;
        createReportViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleDone target:self action:@selector(dismissReportCreation:)];
        return nil;
    }] catch:^(NSError * _Nonnull error) {
        createReportViewController.viewModel = [[ReportViewModel alloc] initWithReport:draft];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"An error occurred" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [createReportViewController presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)createReportViewControllerDidTapCancel:(CreateReportViewController *)createReportViewController {
    [createReportViewController dismissViewControllerAnimated:YES completion:nil];
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

- (void)dismissReportCreation:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
