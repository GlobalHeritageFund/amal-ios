//
//  GalleryCell.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "GalleryCell.h"
#import "UIColor+Additions.h"
#import "CGGeometry.h"

@implementation GalleryHeader

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorWithHex:0x545455];
        label.font = [UIFont fontWithName:@".SFUIDisplay-Semibold" size:16.0];
        [self addSubview:label];
        self.label = label;
    }
    return _label;
}

- (UIView *)separator {
    if (!_separator) {
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor  = [UIColor colorWithHex:0xdcdce0];
        [self addSubview:separator];
        self.separator = separator;
    }
    return _separator;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.label.frame = CGRectInset(self.bounds, 16, 0);

    CGRect separatorRect = self.bounds;
    separatorRect = CGRectTrim(separatorRect, separatorRect.size.height - 1, CGRectMinYEdge);
    self.separator.frame = separatorRect;
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
