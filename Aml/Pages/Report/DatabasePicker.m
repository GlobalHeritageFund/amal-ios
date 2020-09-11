//
//  DatabasePicker.m
//  Amal
//
//  Created by Soroush Khanlou on 8/16/20.
//  Copyright © 2020 Global Heritage Fund. All rights reserved.
//

#import "DatabasePicker.h"
#import "CGGeometry.h"
#import "UIColor+Additions.h"

@interface DatabasePicker ()

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UILabel *valueLabel;
@property (nonatomic) UIImageView *chevronImage;

@end

@implementation DatabasePicker

- (instancetype)init {
    self = [super init];
    if (self) {

        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = [UIColor colorWithHex:0x666666];
        [self addSubview:self.nameLabel];

        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.textColor = [UIColor colorWithHex:0x666666];
        [self addSubview:self.valueLabel];

        self.chevronImage = [[UIImageView alloc] init];
        self.chevronImage.image = [[UIImage imageNamed:@"chevron"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.chevronImage sizeToFit];
        self.chevronImage.contentMode = UIViewContentModeScaleAspectFit;
        self.chevronImage.tintColor = [UIColor colorWithHex:0x666666];
        [self addSubview:self.chevronImage];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.nameLabel sizeToFit];
    [self.valueLabel sizeToFit];

    CGRect nameRect = CGRectZero, valueRect = CGRectZero, chevronRect = CGRectZero;

    CGRect workingRect = self.bounds;

    if (self.enabled) {
        CGRectDivide(workingRect, &chevronRect, &workingRect, 10, CGTrailingEdge());

        workingRect = CGRectTrim(workingRect, 10, CGTrailingEdge());
    }

    CGRectDivide(workingRect, &valueRect, &nameRect, self.valueLabel.bounds.size.width, CGTrailingEdge());

    self.nameLabel.frame = nameRect;
    self.valueLabel.frame = valueRect;
    self.chevronImage.frame = chevronRect;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self setNeedsLayout];
}

@end
