//
//  CALayer+Additions.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "CALayer+Additions.h"

@implementation CALayer (Additions)

- (void)setShadowUIColor:(UIColor*)color
{
    self.shadowColor = [color CGColor];
}

@end
