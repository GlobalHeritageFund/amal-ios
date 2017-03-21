//
//  TextSettingCell.m
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "TextSettingCell.h"

@implementation TextSettingCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.textField.delegate = self;
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    [self.delegate reportValueChange:self.textField.text forCell:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)setValue:(id)value
{
    if([value isKindOfClass:[NSString class]])
        self.textField.text = value;
    else
        self.textField.text = @"";
}

@end
