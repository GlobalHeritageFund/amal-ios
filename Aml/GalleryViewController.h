//
//  GalleryViewController.h
//  Amal
//
//  Created by Dustin Dettmer on 4/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryHeader : UICollectionReusableView

@property (nonatomic) UILabel *label;


@end

@interface PhotoCell : UICollectionViewCell

@property (nonatomic) UIImageView *imageView;


@end

@interface GalleryViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UICollectionView *collectionView;


@end
