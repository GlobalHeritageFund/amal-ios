//
//  GalleryCell.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "GalleryCell.h"

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

- (void)setMode:(GalleryMode)mode {
    _mode = mode;
    if (mode == GalleryModeSelect) {
        [self updateOverlay];
    } else {
        self.overlayView.image = nil;
    }
}

- (void)updateOverlay {
    self.overlayView.image = self.selected ? [UIImage imageNamed:@"ic_img_select_active"] : [UIImage imageNamed:@"ic_img_select"];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
        self.imageView = imageView;
    }
    return _imageView;
}

- (UIImageView *)overlayView {
    if (!_overlayView) {
        UIImageView *overlayView = [[UIImageView alloc] init];
        [self addSubview:overlayView];
        self.overlayView = overlayView;
    }
    return _overlayView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.clipsToBounds = YES;

    [self bringSubviewToFront:self.overlayView];

    CGRect workingRect = self.bounds;
    self.imageView.frame = workingRect;
    workingRect.size.height = 30;
    workingRect.size.width = 30;
    self.overlayView.frame = workingRect;
}

@end
