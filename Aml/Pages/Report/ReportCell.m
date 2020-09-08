//
//  ReportCell.m
//  Amal
//
//  Created by Soroush Khanlou on 8/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportCell.h"
#import "CGGeometry.h"

@implementation ReportCell

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = true;

    CGRect workingRect = self.contentView.bounds;

    CGRect imageRect = CGRectZero, textRect = CGRectZero, detailTextRect;

    CGRectDivide(workingRect, &imageRect, &workingRect, 72, CGLeadingEdge());
    CGRectDivide(workingRect, &textRect, &detailTextRect, 36, CGLeadingEdge());

    self.imageView.frame = CGRectInset(imageRect, 5, 5);
    self.textLabel.frame = CGRectInset(textRect, 5, 0);
    self.detailTextLabel.frame = CGRectInset(detailTextRect, 5, 0);
}

@end
