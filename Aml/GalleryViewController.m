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
#import <Photos/Photos.h>
#import "PhotoStorage.h"
#import "CaptureNotesViewController.h"
#import "GalleryCell.h"
#import "UIColor+Additions.h"

@interface GalleryViewController ()

@property (strong) NSArray<PhotoSection*> *photoSections;
@property (nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic) GalleryMode mode;

@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Gallery";

    self.mode = GalleryModeNormal;

    [self updateBarButtons];

    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.collectionView registerClass:[GalleryHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
}

- (void)updateBarButtons {
    if (self.mode == GalleryModeNormal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(importImage:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(enterSelectMode:)];
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteMultiSelect:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(exitSelectMode:)];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.collectionView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.photoSections = [[PhotoStorage new] fetchGroupedPhotos];
    
    [self.collectionView reloadData];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        collectionView.backgroundColor = [UIColor colorWithHex:0xEFEFF4];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

- (UICollectionViewLayout *)flowLayout {
    if (!_flowLayout) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        layout.sectionInset = UIEdgeInsetsMake(6, 8, 6, 8);

        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 5;
        layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 44);

        NSInteger numberOfColumns = 4;
        CGFloat width = (self.view.bounds.size.width - layout.sectionInset.left - layout.sectionInset.right) / numberOfColumns - layout.minimumInteritemSpacing;
        layout.itemSize = CGSizeMake(width, width);
        self.flowLayout = layout;
    }
    return _flowLayout;
}

- (void)setMode:(GalleryMode)mode {
    _mode = mode;
    self.collectionView.allowsMultipleSelection = (mode == GalleryModeSelect);
    [self.collectionView reloadData];
    [self updateBarButtons];
}

- (void)reloadData {
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)importImage:(id)sender {
    [self startMediaBrowserFromViewController:self.tabBarController usingDelegate:self];
}

- (void)enterSelectMode:(id)sender {
    self.mode = GalleryModeSelect;
}

- (void)exitSelectMode:(id)sender {
    self.mode = GalleryModeNormal;
}

- (void)deleteMultiSelect:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"Are you sure you want to delete these photos? This can not be undone." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
            LocalPhoto *photo = self.photoSections[indexPath.section].photos[indexPath.row];
            [photo unsync];
            [photo removeLocalData];
        }
        [self reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
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
    cell.mode = self.mode;

    if(localPhoto.image)
        cell.imageView.image = localPhoto.image;
    else {
        cell.imageView.image = nil;
        
        [localPhoto load:^(LocalPhoto *localPhoto) {

            if ([collectionView cellForItemAtIndexPath:indexPath] != cell) {
                return;
            }

            cell.imageView.image = localPhoto.image;
        }];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

        PhotoSection *section = self.photoSections[indexPath.section];

        GalleryHeader *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

        reusableview.label.text = [section.header uppercaseString];
        return reusableview;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == GalleryModeNormal) {
        LocalPhoto *localPhoto = self.photoSections[indexPath.section].photos[indexPath.row];
        CaptureNotesViewController *captureNotes = [[CaptureNotesViewController alloc] initWithPhoto:localPhoto];
        [self.navigationController pushViewController:captureNotes animated:YES];
    } else if (self.mode == GalleryModeSelect) {
        PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell updateOverlay];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == GalleryModeSelect) {
        PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell updateOverlay];
    }
    
}

@end
