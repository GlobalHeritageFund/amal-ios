//
//  GalleryViewController.m
//  Amal
//
//  Created by Dustin Dettmer on 4/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "GalleryViewController.h"
#import "PhotoSettings.h"
#import "LocalPhoto.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import "PhotoStorage.h"
#import "CaptureNotesViewController.h"

@implementation GalleryHeader

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [[UILabel alloc] init];
        [self addSubview:label];
        self.label = label;
    }
    return _label;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.label.frame = CGRectInset(self.bounds, 10, 0);
}

@end

@implementation PhotoCell

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        self.imageView = imageView;
    }
    return _imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.frame = self.bounds;
}

@end

static const void *localPhotoKey = &localPhotoKey;

@interface GalleryViewController ()

@property (strong) NSArray<PhotoSection*> *photoSections;
@property (nonatomic) UICollectionViewFlowLayout *flowLayout;


@end

@implementation GalleryViewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        collectionView.backgroundColor = [UIColor whiteColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Assess";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(importImage:)];

    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.collectionView registerClass:[GalleryHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.collectionView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.photoSections = [[PhotoStorage new] fetchGroupedPhotos];
    
    [self.collectionView reloadData];
}

- (UICollectionViewLayout *)flowLayout {
    if (!_flowLayout) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        CGFloat width = (self.view.bounds.size.width - 8 * 2) / 4 - 5;
        layout.itemSize = CGSizeMake(width, width);
        layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 44);

        self.flowLayout = layout;
    }
    return _flowLayout;
}

- (void)reloadData
{
    self.photoSections = [[PhotoStorage new] fetchGroupedPhotos];

    [self.collectionView reloadData];
}

- (BOOL)startMediaBrowserFromViewController: (UIViewController*) controller
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
    
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    
    return YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    PHAsset *asset = [[PHAsset fetchAssetsWithALAssetURLs:@[info[UIImagePickerControllerReferenceURL]] options:nil] firstObject];
    
    __weak GalleryViewController *weakSelf = self;
    
    [PHImageManager.defaultManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        if(!imageData)
            return;
        
        NSNumber *oldLat = PhotoSettings.shared.lat;
        NSNumber *oldLon = PhotoSettings.shared.lon;
        
        PhotoSettings.shared.lat = @(asset.location.coordinate.latitude);
        PhotoSettings.shared.lon = @(asset.location.coordinate.longitude);
        
        [[PhotoStorage new] saveJpegLocally:imageData withSettings:PhotoSettings.shared.settingsDictionary];

        PhotoSettings.shared.lat = oldLat;
        PhotoSettings.shared.lon = oldLon;
        
        GalleryViewController *strongSelf = weakSelf;
        
        [strongSelf reloadData];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)importImage:(id)sender
{
    [self startMediaBrowserFromViewController:self.tabBarController usingDelegate:self];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.photoSections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoSections[section].photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];

    LocalPhoto *localPhoto = self.photoSections[indexPath.section].photos[indexPath.row];
    
    objc_setAssociatedObject(cell, localPhotoKey, localPhoto, OBJC_ASSOCIATION_ASSIGN);
    
    if(localPhoto.image)
        cell.imageView.image = localPhoto.image;
    else {
        cell.imageView.image = nil;
        
        [localPhoto load:^(LocalPhoto *localPhoto) {
            
            if(objc_getAssociatedObject(cell, localPhotoKey) != localPhoto)
                return;

            cell.imageView.image = localPhoto.image;
        }];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

        PhotoSection *section = self.photoSections[indexPath.section];

        GalleryHeader *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

        reusableview.label.text = section.header;
        return reusableview;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LocalPhoto *localPhoto = self.photoSections[indexPath.section].photos[indexPath.row];
    CaptureNotesViewController *captureNotes = [[CaptureNotesViewController alloc] initWithPhoto:localPhoto];
    [self.navigationController pushViewController:captureNotes animated:YES];
}

@end
