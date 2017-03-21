//
//  SegmentSettingCell.m
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "SegmentSettingCell.h"

@implementation SegmentSettingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.segment addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)valueChanged:(id)object
{
    [self.delegate reportValueChange:@(self.segment.selectedSegmentIndex) forCell:self];
}

- (void)setValue:(id)value
{
    if([value isKindOfClass:[NSNumber class]])
        self.segment.selectedSegmentIndex = [value integerValue];
    else
        self.segment.selectedSegmentIndex = UISegmentedControlNoSegment;
}

@end
