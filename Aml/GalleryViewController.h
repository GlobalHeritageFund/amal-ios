//
//  GalleryViewController.h
//  Amal
//
//  Created by Dustin Dettmer on 4/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalleryCell.h"

@class GalleryViewController, LocalPhoto;

@protocol GalleryViewControllerDelegate <NSObject>

- (void)galleryViewController:(GalleryViewController *)galleryViewController didTapPhoto:(LocalPhoto *)photo;
- (void)galleryViewController:(GalleryViewController *)galleryViewController createReportWithPhotos:(NSArray<LocalPhoto *> *)photos;

@end

@interface GalleryViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UICollectionView *collectionView;

@property (nonatomic, weak) id<GalleryViewControllerDelegate> delegate;

@property (nonatomic) GalleryMode mode;

@end
