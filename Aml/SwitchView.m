//
//  SwitchView.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/13/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "SwitchView.h"

@interface SwitchView ()

@property (nonatomic) UILabel *label;
@property (nonatomic) UISwitch *statusSwitch;

@end

@implementation SwitchView

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.label = [[UILabel alloc] init];
        self.label.text = @"EAMENA";
        [self addSubview:self.label];
        
        self.statusSwitch = [[UISwitch alloc] init];
        [self addSubview:self.statusSwitch];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.label sizeToFit];
    
    CGRect labelRect = CGRectZero, switchRect = CGRectZero;
    
    CGRect workingRect = self.bounds;
    
    workingRect = CGRectInset(workingRect, 5, 5);
    
    CGRectDivide(workingRect, &switchRect, &labelRect, self.statusSwitch.bounds.size.width, CGRectMaxXEdge);
    
    self.label.frame = labelRect;
    self.statusSwitch.frame = switchRect;
    
}

@end
