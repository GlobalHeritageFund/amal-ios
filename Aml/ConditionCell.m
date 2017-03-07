//
//  ConditionCell.m
//  Aml
//
//  Created by Dustin Dettmer on 3/7/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "ConditionCell.h"

@interface ConditionCell ()

@property (weak) IBOutlet UISlider *slider;

@end

@implementation ConditionCell

- (IBAction)valueChanged:(UISlider*)slider
{
    slider.value = round(slider.value);
}

@end
