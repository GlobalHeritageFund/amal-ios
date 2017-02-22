//
//  UIButton+Additions.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)

- (IBAction)radioGiveSelection:(UIButton*)sender
{
    self.selected = NO;
    
    sender.selected = YES;
}

@end
