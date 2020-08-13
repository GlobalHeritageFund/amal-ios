//
//  ReportPhotoTableViewCell.m
//  Amal
//
//  Created by Soroush Khanlou on 7/28/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportPhotoTableViewCell.h"

@implementation ReportPhotoTableViewCell

- (UIProgressView *)progressView {
    if (!_progressView) {
        UIProgressView *progressView = [[UIProgressView alloc] init];
        [self.contentView addSubview:progressView];
        self.progressView = progressView;
    }
    return _progressView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = true;

    CGRect workingRect = self.contentView.bounds;

    CGRect imageRect = CGRectZero, textRect = CGRectZero, detailTextRect;

    CGRectDivide(workingRect, &imageRect, &workingRect, 72, CGRectMinXEdge);
    CGRectDivide(workingRect, &textRect, &detailTextRect, 36, CGRectMinYEdge);

    self.imageView.frame = CGRectInset(imageRect, 5, 5);
    self.textLabel.frame = CGRectInset(textRect, 5, 0);
    self.detailTextLabel.frame = CGRectInset(detailTextRect, 5, 0);
    self.progressView.frame = CGRectInset(detailTextRect, 5, 0);
}

@end
