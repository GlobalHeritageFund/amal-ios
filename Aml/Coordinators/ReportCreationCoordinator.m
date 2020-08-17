//
//  ReportCreationCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 8/12/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

@import Firebase;
@import FirebaseUI;
#import "ReportCreationCoordinator.h"
#import "GalleryViewController.h"
#import "ReportDetailViewController.h"
#import "AssessViewController.h"
#import "LocalPhoto.h"
#import "ReportDraft.h"
#import "ReportUpload.h"
#import "LocalDraftDataSource.h"
#import "Report.h"
#import "ImageDetailViewController.h"
#import "CurrentUser.h"
#import "Firebase+Promises.h"
#import "DatabasePickerViewController.h"
#import "NSObject+Helpers.h"

@interface ReportCreationCoordinator () <GalleryViewControllerDelegate, ReportDetailViewControllerDelegate, AssessViewControllerDelegate, FUIAuthDelegate, DatabasePickerViewControllerDelegate>

@property (nonatomic) ReportDraft *currentReport;
@property (nonatomic) ReportDetailViewController *reportDetail;

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
    
    [self updateCurrentReportEmailIfNeeded];

    return self;
}

- (void)updateCurrentReportEmailIfNeeded {
    
    // We may have an email address already, like if the report was a draft or if the user has already edited the field - so we don't want to override it always.
    if (!self.currentReport.email) {
        NSString *currentUserEmail = [CurrentUser shared].emailAddress;
        self.currentReport.email = currentUserEmail;
        
        if (currentUserEmail) {
            self.currentReport.hasPrefilledEmail = YES;
        }
    }
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
        self.reportDetail = reportDetail;
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

- (void)galleryViewController:(GalleryViewController *)galleryViewController batchAssessPhotos:(NSArray<LocalPhoto *> *)photos {
    //not implemented
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController createReportWithPhotos:(NSArray<LocalPhoto *> *)photos {
    [FIRAnalytics logEventWithName:@"report_images_selected" parameters:nil];
    self.currentReport = [[ReportDraft alloc] initWithPhotos:photos];
    [self updateCurrentReportEmailIfNeeded];
    ReportDetailViewController *reportDetail = [[ReportDetailViewController alloc] initWithReportDraft:self.currentReport];
    reportDetail.delegate = self;
    [galleryViewController.navigationController pushViewController:reportDetail animated:YES];
    self.reportDetail = reportDetail;
}

- (void)galleryViewControllerShouldDismiss:(GalleryViewController *)galleryViewController {
    [galleryViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController didTapPhoto:(LocalPhoto *)photo {
    [self.currentReport addPhoto:photo];
    [self.reportDetail updateUploadButtonState];
    [galleryViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)assessViewControllerDidTapEditCoordinates:(AssessViewController *)assessViewController {
    // TODO
    NSLog(@"show map editing vc");
}

- (void)uploadReportFromDetailViewController:(ReportDetailViewController *)reportDetailViewController withDraft:(ReportDraft *)draft {
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

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didTapUploadWithDraft:(ReportDraft *)draft {
    [FIRAnalytics logEventWithName:@"report_upload_tapped" parameters:nil];
    
    if ([CurrentUser shared].isLoggedIn) {
        [self uploadReportFromDetailViewController:reportDetailViewController withDraft:draft];
    } else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Log in" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Log in" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            FUIAuth *auth = [FUIAuth defaultAuthUI];
            UINavigationController *controller = [auth authViewController];
            [reportDetailViewController presentViewController:controller animated:YES completion:nil];
            [[[auth signInPromise] then:^id _Nullable(FIRAuthDataResult * _Nonnull object) {
                [self updateCurrentReportEmailIfNeeded];
                [self uploadReportFromDetailViewController:reportDetailViewController withDraft:draft];
                
                return nil;
            }] catch:^(NSError * _Nonnull error) {
                // Error state :(
            }];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Publish anonymously" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[[[FIRAuth auth] anonymousSignInPromise] then:^id _Nullable(id  _Nonnull object) {
                [self uploadReportFromDetailViewController:reportDetailViewController withDraft:draft];
                return nil;
            }] catch:^(NSError * _Nonnull error) {
                // Error state :(
            }];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [reportDetailViewController presentViewController:alertController animated:YES completion:nil];
        
    }
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

- (void)reportDetailViewControllerDidTapDatabasePicker:(ReportDetailViewController *)reportDetailViewController {
    DatabasePickerViewController *picker = [[DatabasePickerViewController alloc] init];

    picker.selectedDatabase = reportDetailViewController.viewModel.databaseTarget;

    picker.delegate = self;

    [reportDetailViewController.navigationController pushViewController:picker animated:YES];
}

- (void)databasePicker:(DatabasePickerViewController *)picker didPickNewDatabase:(DatabaseTarget)target {
    self.currentReport.databaseTarget = target;

    [self.reportDetail configureView];

    [picker.navigationController popViewControllerAnimated:YES];
}

- (void)dismissReportCreation:(id)sender {
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
