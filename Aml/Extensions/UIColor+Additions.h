//
//  UIColor+Color.h
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

+ (UIColor *)colorWithHex:(NSInteger)hex;

+ (UIColor *)colorWithHex:(NSInteger)hex withAlpha:(CGFloat)alpha;

+ (UIColor *)amalTeal;

+ (UIColor *)backgroundColor;

@end
