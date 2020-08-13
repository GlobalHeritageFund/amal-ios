//
//  UIColor+Color.m
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (UIColor *)colorWithHex:(NSInteger)hex {
    return [self colorWithHex:hex withAlpha:1.0f];
}

+ (UIColor *)colorWithHex:(NSInteger)hex withAlpha:(CGFloat)alpha {

    CGFloat r = ((hex & 0xFF0000) >> 16) / 255.0;
    CGFloat g = ((hex & 0x00FF00) >> 8 ) / 255.0;
    CGFloat b = ((hex & 0x0000FF)      ) / 255.0;

    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

+ (UIColor *)amalTeal {
    return [UIColor colorWithHex:0x16a7c7];
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithHex:0xEFEFF4];
}

@end
