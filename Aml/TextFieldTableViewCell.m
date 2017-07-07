//
//  TextFieldTableViewCell.m
//  Amal
//
//  Created by Soroush Khanlou on 7/7/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "TextFieldTableViewCell.h"

@implementation TextFieldTableViewCell

- (void)setHostedTextfield:(UITextField *)hostedTextfield {
    _hostedTextfield = hostedTextfield;
    [self addSubview:hostedTextfield];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.hostedTextfield.frame = CGRectInset(self.bounds, 10, 5);
}

@end
