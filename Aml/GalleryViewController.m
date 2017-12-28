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
#import "Firebase.h"
#import "EmptyStateView.h"
#import "CGGeometry.h"

@interface GalleryViewController ()

@property (strong) NSArray<PhotoSection*> *photoSections;
@property (nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic) UIToolbar *toolbar;
@property (nonatomic) EmptyStateView *emptyState;

@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Assess";

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

    self.emptyState.frame = CGRectInsetToSize(self.view.bounds, CGSizeMake(300, 400));

    self.collectionView.frame = workingRect;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        collectionView.backgroundColor = [UIColor backgroundColor];
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

- (EmptyStateView *)emptyState {
    if (!_emptyState) {
        EmptyStateView *emptyState = [[EmptyStateView alloc] init];
        emptyState.imageView.image = [UIImage imageNamed:@"gallery_bg"];
        emptyState.label.text = @"As you take photos, your gallery will store those photos.";
        [self.view addSubview:emptyState];
        self.emptyState = emptyState;
    }
    return _emptyState;
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

    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveSelectedItems:)];
    [items addObject:saveItem];

    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpace2];

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

    BOOL isEmpty = self.photoSections.count == 0 || (self.photoSections.count == 1 && self.photoSections.firstObject.photos.count == 0);

    self.emptyState.hidden = !isEmpty;
}

- (void)importImage:(id)sender {
    [self.delegate galleryViewControllerDidTapImport:self];
}

- (void)enterSelectMode:(id)sender {
    self.mode = GalleryModeMultiSelect;
}

- (void)exitSelectMode:(id)sender {
    self.mode = GalleryModeNormal;
}

- (void)deleteMultiSelect:(id)sender {
    NSArray<LocalPhoto *> *photos = [self.collectionView.indexPathsForSelectedItems arrayByTransformingObjectsUsingBlock:^LocalPhoto *(NSIndexPath *indexPath) {
        return self.photoSections[indexPath.section].photos[indexPath.row];
    }];
    [self.delegate galleryViewController:self deletePhotos:photos];
}

- (void)saveSelectedItems:(id)sender {
    NSArray<LocalPhoto *> *photos = [self.collectionView.indexPathsForSelectedItems arrayByTransformingObjectsUsingBlock:^LocalPhoto *(NSIndexPath *indexPath) {
        return self.photoSections[indexPath.section].photos[indexPath.row];
    }];
    [self.delegate galleryViewController:self savePhotos:photos];
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

    [[localPhoto loadThumbnailImage] then:^id _Nullable(id  _Nonnull object) {
        if ([collectionView cellForItemAtIndexPath:indexPath] != nil) {
            cell.imageView.image = object;
        }
        return nil;
    }];

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
