//
//  SwitchSettingCell.m
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "SwitchSettingCell.h"

@implementation SwitchSettingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.switchRef addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)valueChanged:(id)object
{
    [self.delegate reportValueChange:@(self.switchRef.on) forCell:self];
}

- (void)setValue:(id)value
{
    if([value isKindOfClass:[NSNumber class]])
        self.switchRef.on = [value boolValue];
    else
        self.switchRef.on = 0;
}

@end
