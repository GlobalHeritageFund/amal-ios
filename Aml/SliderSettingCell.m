//
//  SliderSettingCell.m
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "SliderSettingCell.h"

@implementation SliderSettingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)valueChanged:(id)object
{
    if(self.roundValueChanges)
        self.slider.value = round(self.slider.value);
    
    [self.delegate reportValueChange:@(self.slider.value) forCell:self];
}

- (void)setValue:(id)value
{
    if([value isKindOfClass:[NSNumber class]])
        self.slider.value = [value floatValue];
    else
        self.slider.value = 0;
}

@end
