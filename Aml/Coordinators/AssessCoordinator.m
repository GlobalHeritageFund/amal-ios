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
#import "EditLocationViewController.h"
#import "MultiAssessViewController.h"

@interface AssessCoordinator() <GalleryViewControllerDelegate, QBImagePickerControllerDelegate, AssessViewControllerDelegate, EditLocationViewControllerDelegate>

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) NSMutableArray *childCoordinators;
@property (nonatomic) LocalPhoto *currentlyAssessing;

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
    galleryViewController.shouldShowFilterButton = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:galleryViewController];
    galleryViewController.delegate = self;
    navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"header.assess", @"A tab bar button label that takes you to the Assess tab.") image:[UIImage imageNamed:@"ic_assess"] selectedImage:[UIImage imageNamed:@"ic_assess"]];
    self.navigationController = navigationController;

}

- (void)galleryViewController:(GalleryViewController *)galleryViewController didTapPhoto:(LocalPhoto *)photo {
    self.currentlyAssessing = photo;
    AssessViewController *assess = [[AssessViewController alloc] initWithPhoto:photo];
    assess.delegate = self;
    [galleryViewController.navigationController pushViewController:assess animated:YES];
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
    NSString *key = NSLocalizedString(@"warning.delete-photos.interpolation", @"A warning that appears when you want to delete one or more photos. #bc-ignore!");
    NSString *message = [NSString localizedStringWithFormat:key, photos.count];
    [FIRAnalytics logEventWithName:@"multi_select_delete" parameters:@{ @"count": @(photos.count) }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"header.are-you-sure", @"A header for a warning that appears when you want to delete one or more photos.") message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.delete", @"A button to delete one or more images.") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        for (LocalPhoto *photo in photos) {
            [photo removeLocalData];
        }
        [galleryViewController reloadData];
        galleryViewController.mode = GalleryModeNormal;
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", @"A standard cancel button.") style:UIAlertActionStyleCancel handler:nil]];
    [galleryViewController presentViewController:alertController animated:true completion:nil];
}

- (void)galleryViewController:(GalleryViewController *)galleryViewController batchAssessPhotos:(NSArray<LocalPhoto *> *)photos {
    MultiAssessViewController *multiAssess = [[MultiAssessViewController alloc] initWithPhotos:photos];
    [self.navigationController pushViewController:multiAssess animated:YES];
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

- (void)assessViewControllerDidTapEditCoordinates:(AssessViewController *)assessViewController {
    AMLMetadata *metadata = assessViewController.photo.metadata;
    EditLocationViewController *editLocation = metadata.hasLocationCoordinates
    ? [[EditLocationViewController alloc] initWithLocation:assessViewController.photo.metadata.coordinate]
    : [[EditLocationViewController alloc] initGlobally];
    editLocation.delegate = self;
    [self.navigationController pushViewController:editLocation animated:YES];
}

- (void)editLocationViewControllerUpdateLocationButtonTapped:(EditLocationViewController *)editLocationViewController {
    CLLocationCoordinate2D location = editLocationViewController.mapView.centerCoordinate;
    LocalPhoto *photo = self.currentlyAssessing;

    photo.metadata.latitude = location.latitude;
    photo.metadata.longitude = location.longitude;
    [photo saveMetadata];
    [editLocationViewController resetUpdateButton];
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
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"header.duplicate-found", @"A title for a warning that some duplicate photos were found during import.") message:NSLocalizedString(@"warning.duplicate-found", @"A warning that shows up if one of the photos you are trying to import has already been imported.") preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.ok", @"A standard OK button.") style:UIAlertActionStyleDefault handler:nil]];
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
