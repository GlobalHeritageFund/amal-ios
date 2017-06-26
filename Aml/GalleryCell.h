//
//  GalleryCell.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryHeader : UICollectionReusableView

@property (nonatomic) UILabel *label;

@end


@interface PhotoCell : UICollectionViewCell

@property (nonatomic) UIImageView *imageView;

@end
