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

@end

@implementation ReportCreationCoordinator

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (!self) return nil;

    _viewController = viewController;

    return self;
}

- (void)start {
    GalleryViewController *galleryViewController = [[GalleryViewController alloc] init];
    [galleryViewController loadViewIfNeeded];
    UINavigationController *galleryNavigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    galleryViewController.mode = GalleryModeCreateReport;
    galleryViewController.delegate = self;
    [self.viewController presentViewController:galleryNavigationController animated:true completion:nil];
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController createReportWithPhotos:(NSArray<LocalPhoto *> *)photos {
    ReportDraft *report = [[ReportDraft alloc] initWithPhotos:photos];
    CreateReportViewController *createReport = [[CreateReportViewController alloc] initWithReportDraft:report];
    createReport.delegate = self;
    [galleryViewController.navigationController pushViewController:createReport animated:YES];
}

- (void)galleryViewControllerShouldDismiss:(GalleryViewController *)galleryViewController {
    [galleryViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController didTapPhoto:(LocalPhoto *)photo {
    //unimplemented
}

- (void)createReportViewController:(CreateReportViewController *)createReportViewController didTapUploadWithDraft:(ReportDraft *)draft {
    createReportViewController.title = @"Uploading...";
    createReportViewController.uploadButton.enabled = NO;

    ReportUpload *upload = [[ReportUpload alloc] initWithReportDraft:draft];
    createReportViewController.upload = upload;

    [upload upload];
    [[upload.promise then:^id _Nullable(id  _Nonnull object) {
        createReportViewController.title = @"Uploaded!";
        createReportViewController.navigationItem.hidesBackButton = YES;
        createReportViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dismiss" style:UIBarButtonItemStyleDone target:self action:@selector(dismissReportCreation:)];
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

- (void)dismissReportCreation:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
