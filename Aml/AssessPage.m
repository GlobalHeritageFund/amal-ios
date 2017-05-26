//
//  AssessPage.m
//  Amal
//
//  Created by Dustin Dettmer on 4/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "AssessPage.h"
#import "PhotoSettings.h"
#import "LocalPhoto.h"
#import "CaptureNotesPage.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>

static const void *localPhotoKey = &localPhotoKey;

@interface AssessPage ()

@property (strong) NSArray<LocalPhoto*> *localImages;

@end

@implementation AssessPage

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.localImages = PhotoSettings.shared.localPhotos;
    
    [self.collectionView reloadData];
}

- (void)reloadData
{
    self.localImages = PhotoSettings.shared.localPhotos;
    
    [self.collectionView reloadData];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    mediaUI.allowsEditing = YES;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[info[UIImagePickerControllerReferenceURL]] options:nil] firstObject];
    
    __weak AssessPage *weakSelf = self;
    
    [PHImageManager.defaultManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        if(!imageData)
            return;
        
        NSNumber *oldLat = PhotoSettings.shared.lat;
        NSNumber *oldLon = PhotoSettings.shared.lon;
        
        PhotoSettings.shared.lat = @(asset.location.coordinate.latitude);
        PhotoSettings.shared.lon = @(asset.location.coordinate.longitude);
        
        [PhotoSettings.shared saveJpegLocally:imageData];
        
        PhotoSettings.shared.lat = oldLat;
        PhotoSettings.shared.lon = oldLon;
        
        AssessPage *strongSelf = weakSelf;
        
        [strongSelf reloadData];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)importImage:(id)sender
{
    [self startMediaBrowserFromViewController:self.tabBarController usingDelegate:self];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.localImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *imageView = (id)[cell viewWithTag:1];
    
    LocalPhoto *localPhoto = self.localImages[indexPath.row];
    
    objc_setAssociatedObject(cell, localPhotoKey, localPhoto, OBJC_ASSOCIATION_ASSIGN);
    
    if(localPhoto.image)
        imageView.image = localPhoto.image;
    else {
        
        imageView.image = nil;
        
        [localPhoto load:^(LocalPhoto *localPhoto) {
            
            if(objc_getAssociatedObject(cell, localPhotoKey) != localPhoto)
                return;
            
            UIImageView *imageView = (id)[cell viewWithTag:1];
            
            imageView.image = localPhoto.image;
        }];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat v = (self.view.bounds.size.width - 8 * 2) / 4 - 5;
    
    return CGSizeMake(v, v);
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqual:@"imageTap"]) {
        
        return [objc_getAssociatedObject(sender, localPhotoKey) image] != nil;
    }
    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqual:@"imageTap"]) {
        
        CaptureNotesPage *page = segue.destinationViewController;
        
        page.localPhoto = objc_getAssociatedObject(sender, localPhotoKey);
    }
}

@end
