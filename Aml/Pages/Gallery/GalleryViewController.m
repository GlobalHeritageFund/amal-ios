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
#import "EmptyState.h"
#import "CGGeometry.h"
#import "LocalPhotoFilter.h"
@interface GalleryViewController ()

@property (strong) NSArray<PhotoSection*> *photoSections;
@property (nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic) UIToolbar *toolbar;
@property (nonatomic) EmptyStateView *emptyState;
@property (nonatomic) UIButton *filterButton;
@property (nonatomic) id<LocalPhotoFilter> currentFilter;

@end

@implementation GalleryViewController

@synthesize currentFilter = _currentFilter;

- (id<LocalPhotoFilter>)currentFilter {
    if (!_currentFilter) {
        self.currentFilter = [[DefaultPhotoFilter alloc] init];
    }
    return _currentFilter;
}

- (void)setCurrentFilter:(id<LocalPhotoFilter>)currentFilter {
    _currentFilter = currentFilter;

    NSString *buttonTitle = [[NSString localizedStringWithFormat:NSLocalizedString(@"Filter", @"A description for a filter that can be applied to a list of photos."), self.currentFilter.name] localizedUppercaseString];
    [self.filterButton setTitle:buttonTitle forState:UIControlStateNormal];
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    self.title = NSLocalizedString(@"Assess", @"A heading for the Assess screen.");

    self.view.backgroundColor = [UIColor backgroundColor];

    self.mode = GalleryModeNormal;

    [self updateBarButtons];

    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.collectionView registerClass:[GalleryHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
}

- (void)updateBarButtons {
    if (self.mode == GalleryModeNormal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Import", @"A button that imports photos from the user's library.") style:UIBarButtonItemStylePlain target:self action:@selector(importImage:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Select", @"A button that enters a mode where users can select more on than one photo to take action on it.") style:UIBarButtonItemStylePlain target:self action:@selector(enterSelectMode:)];
    } else if (self.mode == GalleryModeMultiSelect) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"A standard cancel button.") style:UIBarButtonItemStylePlain target:self action:@selector(exitSelectMode:)];
    } else if (self.mode == GalleryModeSingleSelect) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"A standard cancel button.") style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
        self.navigationItem.rightBarButtonItem = nil;
    } else if (self.mode == GalleryModeCreateReport) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"A standard cancel button.") style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create Report", @"A button to create a report from some selected photos.") style:UIBarButtonItemStylePlain target:self action:@selector(createReport:)];
        self.navigationItem.rightBarButtonItem.enabled = false;
    } else {
        @throw [NSException new];
    }
}

- (CGFloat)bottomSpacingForToolbar {
    if (@available(iOS 11.0, *)) {
        return self.view.window.safeAreaInsets.bottom;
    }
    return 0;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect workingRect = self.view.bounds;

    CGRect toolbarRect = CGRectZero, discardableRect = CGRectZero, filterButtonRect = CGRectZero;

    if (!self.toolbar.hidden) {
        CGRect toolbarWorkingRect = CGRectTrim(workingRect, self.bottomSpacingForToolbar, CGRectMaxYEdge);
        CGRectDivide(toolbarWorkingRect, &toolbarRect, &discardableRect, 44, CGRectMaxYEdge);
    }

    self.toolbar.frame = toolbarRect;

    self.emptyState.frame = CGRectInsetToSize(self.view.bounds, CGSizeMake(300, 400));

    CGFloat topLayoutGuide = [self.topLayoutGuide length];
    CGFloat bottomLayoutGuide = [self.bottomLayoutGuide length];

    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, bottomLayoutGuide, 0);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, bottomLayoutGuide, 0);

    workingRect = CGRectTrim(workingRect, topLayoutGuide, CGRectMinYEdge);

    if (self.shouldShowFilterButton) {
        CGRectDivide(workingRect, &filterButtonRect, &workingRect, 40, CGRectMinYEdge);
    }

    self.filterButton.frame = CGRectInset(filterButtonRect, 15, 0);
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
        if (@available(iOS 10.0, *)) {
            collectionView.prefetchingEnabled = NO;
        }
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
        emptyState.label.text = NSLocalizedString(@"As you take photos, your gallery will store those photos.", @"A label that explains the gallery to users who have not taken any photos yet.");
        [self.view addSubview:emptyState];
        self.emptyState = emptyState;
    }
    return _emptyState;
}

- (UIButton *)filterButton {
    if (!_filterButton) {
        UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeSystem];
        if (@available(iOS 11.0, *)) {
            filterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentTrailing;
        } else {
            filterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        };
        [filterButton addTarget:self action:@selector(filterButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:filterButton];
        self.filterButton = filterButton;
    }
    return _filterButton;
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

    UIBarButtonItem *createReportItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create Report", @"A button to create a report from some selected photos.") style:UIBarButtonItemStylePlain target:self action:@selector(createReport:)];
    [items addObject:createReportItem];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpace];

    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"A button to save some selected photos to their device's photo library.") style:UIBarButtonItemStylePlain target:self action:@selector(saveSelectedItems:)];
    [items addObject:saveItem];

    UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpace2];

    UIBarButtonItem *assessItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Assess", @"A button to assess some selected photos.") style:UIBarButtonItemStylePlain target:self action:@selector(multiAssess:)];
    [items addObject:assessItem];

    UIBarButtonItem *flexibleSpace3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpace3];

    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteMultiSelect:)];
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
    self.photoSections = [[PhotoStorage new] fetchGroupedPhotosWithFilter:self.currentFilter];

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

- (NSArray<LocalPhoto *> *)selectedPhotos {
    return [self.collectionView.indexPathsForSelectedItems arrayByTransformingObjectsUsingBlock:^LocalPhoto *(NSIndexPath *indexPath) {
        return self.photoSections[indexPath.section].photos[indexPath.row];
    }];
}

- (void)deleteMultiSelect:(id)sender {
    [self.delegate galleryViewController:self deletePhotos:self.selectedPhotos];
}

- (void)multiAssess:(id)sender {
    NSArray<LocalPhoto *> *selectedPhotos = self.selectedPhotos;
    if (selectedPhotos.count == 1) {
        [self.delegate galleryViewController:self didTapPhoto:self.selectedPhotos.firstObject];
    } else {
        [self.delegate galleryViewController:self batchAssessPhotos:self.selectedPhotos];
    }
}

- (void)saveSelectedItems:(id)sender {
    [self.delegate galleryViewController:self savePhotos:self.selectedPhotos];
}

- (void)dismiss:(id)sender {
    [self.delegate galleryViewControllerShouldDismiss:self];
}

- (void)createReport:(id)sender {
    [self.delegate galleryViewController:self createReportWithPhotos:self.selectedPhotos];
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

        reusableview.label.text = [section.header localizedUppercaseString];
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

- (void)filterButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray<id<LocalPhotoFilter>> *filters = @[[DefaultPhotoFilter new], [AssessedPhotoFilter new], [UnassessedPhotoFilter new]];
    NSArray<UIAlertAction *> *actions = [filters  arrayByTransformingObjectsUsingBlock:^id(id<LocalPhotoFilter> filter) {
        NSString *name;
        if ([filter.name isEqualToString:self.currentFilter.name]) {
            name = [NSString stringWithFormat:@"%@ ✓", filter.name];
        } else {
            name = filter.name;
        }
        return [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.currentFilter = filter;
        }];
    }];

    for (UIAlertAction *action in actions) {
        [alertController addAction:action];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"A standard cancel button.") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //do nothing
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.mode == GalleryModeMultiSelect || self.mode == GalleryModeCreateReport) {
        PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell updateOverlay];
        [self updateEnabledStateOnToolbarItems];
    }
    
}

@end
