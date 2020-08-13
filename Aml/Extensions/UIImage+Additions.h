//
//  UIImage+Additions.h
//  Amal
//
//  Created by Soroush Khanlou on 8/3/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promise.h"

@interface UIImage (Additions)

+ (Promise<UIImage *> *)promisedImageWithContentsOfFile:(NSString *)path;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
