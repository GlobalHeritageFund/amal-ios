//
//  EmptyStateView.m
//  Amal
//
//  Created by Soroush Khanlou on 12/27/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "EmptyStateView.h"

@implementation EmptyStateView

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        self.imageView = imageView;
    }
    return _imageView;
}

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 0;
        label.textColor = [UIColor darkGrayColor];
        [self addSubview:label];
        self.label = label;
    }
    return _label;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect workingRect = self.bounds;

    CGRect imageRect = CGRectZero, labelRect = CGRectZero;

    CGRectDivide(workingRect, &imageRect, &labelRect, self.imageView.image.size.height, CGRectMinYEdge);

    self.imageView.frame = imageRect;
    self.label.frame = labelRect;

}

@end
