//
//  GalleryCell.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "GalleryCell.h"
#import "UIColor+Additions.h"
#import "CGGeometry.h"

@implementation GalleryHeader

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorWithHex:0x4A4A4A];
        label.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
        [self addSubview:label];
        self.label = label;
    }
    return _label;
}

- (UIView *)separator {
    if (!_separator) {
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor  = [UIColor colorWithHex:0xC7C7CC];
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
    if (mode == GalleryModeMultiSelect || mode == GalleryModeCreateReport) {
        [self updateOverlay];
    } else {
        self.overlayView.image = nil;
    }
    [self setNeedsLayout];
}

- (void)updateOverlay {
    self.overlayView.image = self.selected ? [UIImage imageNamed:@"ic_img_select_active"] : [UIImage imageNamed:@"ic_img_select"];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return _imageView;
}

- (UIImageView *)overlayView {
    if (!_overlayView) {
        UIImageView *overlayView = [[UIImageView alloc] init];
        [self.contentView addSubview:overlayView];
        self.overlayView = overlayView;
    }
    return _overlayView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.clipsToBounds = YES;

    [self.contentView bringSubviewToFront:self.overlayView];

    [self.contentView sendSubviewToBack:self.imageView];

    CGRect workingRect = self.bounds;
    self.imageView.frame = workingRect;
    workingRect.size.height = 30;
    workingRect.size.width = 30;
    self.overlayView.frame = workingRect;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
}

@end
