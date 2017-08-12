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
#import "LocalPhoto.h"
#import "ReportDraft.h"

@interface ReportCreationCoordinator () <GalleryViewControllerDelegate>

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
    //set up bar buttons for dismissal
    [galleryViewController.navigationController pushViewController:createReport animated:YES];
}

- (void)galleryViewControllerShouldDismiss:(GalleryViewController *)galleryViewController {
    [galleryViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController didTapPhoto:(LocalPhoto *)photo {
    //unimplemented
}

@end
