//
//  GalleryCell.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GalleryMode) {
    GalleryModeSelect,
    GalleryModeNormal,
};

@interface GalleryHeader : UICollectionReusableView

@property (nonatomic) UILabel *label;

@end


@interface PhotoCell : UICollectionViewCell

@property (nonatomic) GalleryMode mode;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImageView *overlayView;

- (void)updateOverlay;

@end
