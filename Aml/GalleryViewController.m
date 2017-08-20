//
//  GalleryViewController.m
//  Amal
//
//  Created by Dustin Dettmer on 4/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "GalleryViewController.h"
#import "PhotoSettings.h"
#import "LocalPhoto.h"
#import <Photos/Photos.h>
#import "PhotoStorage.h"
#import "GalleryCell.h"
#import "UIColor+Additions.h"
#import "AMLMetadata.h"
#import "ReportDraft.h"
#import "NSArray+Additions.h"
#import "Promise.h"

@interface GalleryViewController ()

@property (strong) NSArray<PhotoSection*> *photoSections;
@property (nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic) UIToolbar *toolbar;

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
    } else if (self.mode == GalleryModeMultiSelect) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(exitSelectMode:)];
    } else if (self.mode == GalleryModeSingleSelect) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
        self.navigationItem.rightBarButtonItem = nil;
    } else if (self.mode == GalleryModeCreateReport) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create Report" style:UIBarButtonItemStylePlain target:self action:@selector(createReport:)];
        self.navigationItem.rightBarButtonItem.enabled = false;
    } else {
        @throw [NSException new];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect workingRect = self.view.bounds;

    CGRect toolbarRect = CGRectZero, discardableRect = CGRectZero;

    if (!self.toolbar.hidden) {
        CGRectDivide(workingRect, &toolbarRect, &discardableRect, 44, CGRectMaxYEdge);
    }
    
    self.toolbar.frame = toolbarRect;

    self.collectionView.frame = workingRect;
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
        collectionView.alwaysBounceVertical = YES;
        collectionView.dataSource = self;
        collectionView.prefetchingEnabled = NO;
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

- (UIToolbar *)toolbar {
    if (!_toolbar) {
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        [self.view addSubview:toolbar];
        self.toolbar = toolbar;
    }
    return _toolbar;
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
    self.collectionView.allowsMultipleSelection = (mode == GalleryModeMultiSelect || mode == GalleryModeCreateReport);
    [self.collectionView reloadData];
    [self updateBarButtons];
    self.tabBarController.tabBar.hidden = (mode == GalleryModeMultiSelect);
    self.toolbar.hidden = (mode == GalleryModeNormal || mode == GalleryModeCreateReport);
    [self setupToolbar];
    [self updateEnabledStateOnToolbarItems];
    [self.view setNeedsLayout];
}

- (void)setupToolbar {
    NSMutableArray *items = [NSMutableArray array];

    UIBarButtonItem *createReportItem = [[UIBarButtonItem alloc] initWithTitle:@"Create Report" style:UIBarButtonItemStylePlain target:self action:@selector(createReport:)];
    [items addObject:createReportItem];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpace];

    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteMultiSelect:)];
    deleteItem.tintColor = [UIColor redColor];
    [items addObject:deleteItem];

    self.toolbar.items = items;
}

- (NSArray <LocalPhoto *>*)allPhotos {
    return [self.photoSections valueForKeyPath:@"@unionOfArrays.photos"];
}

- (void)updateEnabledStateOnToolbarItems {
    BOOL hasSelectedAnyItems = self.collectionView.indexPathsForSelectedItems.count != 0;
    for (UIBarButtonItem *item in self.toolbar.items) {
        item.enabled = hasSelectedAnyItems;
    }

    if (self.mode == GalleryModeCreateReport) {
        self.navigationItem.rightBarButtonItem.enabled = hasSelectedAnyItems;
    }

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

        AMLMetadata *metadata = [AMLMetadata new];

        metadata.latitude = asset.location.coordinate.latitude;
        metadata.longitude = asset.location.coordinate.longitude;
        metadata.date = asset.creationDate;
        metadata.localIdentifier = asset.localIdentifier;

        if ([self.allPhotos indexOfObjectPassingTest:^BOOL(LocalPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) { return [obj.metadata.localIdentifier isEqualToString:metadata.localIdentifier]; }] != NSNotFound) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Duplicate found" message:@"This photo has already been imported." preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }

        [[PhotoStorage new] saveJpegLocally:imageData withMetadata:metadata];

        [weakSelf reloadData];
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
    self.mode = GalleryModeMultiSelect;
}

- (void)exitSelectMode:(id)sender {
    self.mode = GalleryModeNormal;
}

- (void)deleteMultiSelect:(id)sender {
    NSString *message;
    if (self.collectionView.indexPathsForSelectedItems.count == 1) {
        message = @"Are you sure you want to delete this photo? This can not be undone.";
    } else {
        message = @"Are you sure you want to delete these photos? This can not be undone.";
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        for (NSIndexPath *indexPath in self.collectionView.indexPathsForSelectedItems) {
            LocalPhoto *photo = self.photoSections[indexPath.section].photos[indexPath.row];
            [photo removeLocalData];
        }
        [self reloadData];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)dismiss:(id)sender {
    [self.delegate galleryViewControllerShouldDismiss:self];
}

- (void)createReport:(id)sender {
    NSArray<LocalPhoto *> *photos = [self.collectionView.indexPathsForSelectedItems arrayByTransformingObjectsUsingBlock:^LocalPhoto *(NSIndexPath *indexPath) {
        return self.photoSections[indexPath.section].photos[indexPath.row];
    }];
    [self.delegate galleryViewController:self createReportWithPhotos:photos];
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

    if(localPhoto.image) {
        cell.imageView.image = localPhoto.image;
    } else {
        [[localPhoto loadImage] then:^id _Nullable(id  _Nonnull object) {
            if ([collectionView cellForItemAtIndexPath:indexPath] != nil) {
                cell.imageView.image = localPhoto.image;
            }
            return nil;
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
    if (self.mode == GalleryModeNormal || self.mode == GalleryModeSingleSelect) {
        LocalPhoto *localPhoto = self.photoSections[indexPath.section].photos[indexPath.row];
        [self.delegate galleryViewController:self didTapPhoto:localPhoto];
    } else if (self.mode == GalleryModeMultiSelect || self.mode == GalleryModeCreateReport) {
        PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell updateOverlay];
        [self updateEnabledStateOnToolbarItems];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == GalleryModeMultiSelect || self.mode == GalleryModeCreateReport) {
        PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell updateOverlay];
        [self updateEnabledStateOnToolbarItems];
    }
    
}

@end
