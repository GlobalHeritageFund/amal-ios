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
    self.label.center = CGPointMake(10 + self.label.bounds.size.width / 2, self.bounds.size.height / 2);
    self.statusSwitch.center = CGPointMake(self.bounds.size.width - self.label.bounds.size.width / 2, self.bounds.size.height / 2);
}

@end
