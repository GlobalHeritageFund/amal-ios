//
//  AssessCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 12/14/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "AssessCoordinator.h"
#import "GalleryViewController.h"
#import "AssessViewController.h"
#import "Firebase.h"
#import "ReportCreationCoordinator.h"
#import "ReportDraft.h"
#import "QBImagePickerController.h"
#import "LocalPhoto.h"
#import "AMLMetadata.h"
#import "PhotoStorage.h"
#import "NSObject+Helpers.h"

@interface AssessCoordinator() <GalleryViewControllerDelegate, QBImagePickerControllerDelegate>

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) NSMutableArray *childCoordinators;

@end

@implementation AssessCoordinator

- (NSMutableArray *)childCoordinators {
    if (!_childCoordinators) {
        self.childCoordinators = [NSMutableArray array];
    }
    return _childCoordinators;
}

- (void)start {

    GalleryViewController *galleryViewController = [[GalleryViewController alloc] init];
    galleryViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    galleryViewController.delegate = self;
    navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Assess" image:[UIImage imageNamed:@"ic_assess"] selectedImage:[UIImage imageNamed:@"ic_assess"]];
    self.navigationController = navigationController;

}

- (void)galleryViewController:(GalleryViewController *)galleryViewController didTapPhoto:(LocalPhoto *)photo {
    AssessViewController *captureNotes = [[AssessViewController alloc] initWithPhoto:photo];
    [galleryViewController.navigationController pushViewController:captureNotes animated:YES];
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController createReportWithPhotos:(NSArray<LocalPhoto *> *)photos {

    [FIRAnalytics logEventWithName:@"multi_create_report" parameters:@{ @"count": @(photos.count) }];
    galleryViewController.mode = GalleryModeNormal;

    ReportDraft *report = [[ReportDraft alloc] initWithPhotos:photos];

    ReportCreationCoordinator *reportCreation = [[ReportCreationCoordinator alloc] initWithViewController:galleryViewController reportDraft:report];
    [reportCreation start];
    [self.childCoordinators addObject:reportCreation];
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController savePhotos:(NSArray<LocalPhoto *> *)photos {
    [FIRAnalytics logEventWithName:@"multi_save_images" parameters:@{ @"count": @(photos.count) }];

    for (LocalPhoto *photo in photos) {
        [[photo loadFullSizeImage] then:^id _Nullable(id  _Nonnull image) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                changeRequest.location = [[CLLocation alloc] initWithLatitude:photo.metadata.latitude longitude:photo.metadata.longitude];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {

            }];
            return nil;
        }];
    }
    galleryViewController.mode = GalleryModeNormal;
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController deletePhotos:(NSArray<LocalPhoto *> *)photos {
    NSString *message;
    if (photos.count == 1) {
        message = @"Are you sure you want to delete this photo? This can not be undone.";
    } else {
        message = @"Are you sure you want to delete these photos? This can not be undone.";
    }
    [FIRAnalytics logEventWithName:@"multi_select_delete" parameters:@{ @"count": @(photos.count) }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        for (LocalPhoto *photo in photos) {
            [photo removeLocalData];
        }
        [galleryViewController reloadData];
        galleryViewController.mode = GalleryModeNormal;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [galleryViewController presentViewController:alertController animated:true completion:nil];
}

- (void)galleryViewControllerShouldDismiss:(GalleryViewController *)galleryViewController {
    [galleryViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)galleryViewControllerDidTapImport:(GalleryViewController *)galleryViewController {

    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 50;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;

    [self.navigationController presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)qb_imagePickerController:(QBImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets {

    [FIRAnalytics logEventWithName:@"imported_images" parameters:@{ @"count": @(assets.count) }];

    for (PHAsset *asset in assets) {
        [self importAsset:asset];
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)importAsset:(PHAsset *)asset {
    [PHImageManager.defaultManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {

        if(!imageData)
            return;

        AMLMetadata *metadata = [AMLMetadata new];

        metadata.latitude = asset.location.coordinate.latitude;
        metadata.longitude = asset.location.coordinate.longitude;
        metadata.date = asset.creationDate;
        metadata.localIdentifier = asset.localIdentifier;

        if ([[[PhotoStorage new] fetchPhotos] indexOfObjectPassingTest:^BOOL(LocalPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { return [obj.metadata.localIdentifier isEqualToString:metadata.localIdentifier]; }] != NSNotFound) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Duplicate found" message:@"This photo has already been imported. This won't affect other photos you're importing." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
            return;
        }

        [[PhotoStorage new] saveJpegLocally:imageData withMetadata:metadata];

        [[[self.navigationController topViewController] asClassOrNil:[GalleryViewController class]] reloadData];

    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
