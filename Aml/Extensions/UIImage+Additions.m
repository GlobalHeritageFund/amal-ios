//
//  UIImage+Additions.m
//  Amal
//
//  Created by Soroush Khanlou on 8/3/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (Promise<UIImage *> *)promisedImageWithContentsOfFile:(NSString *)path {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(UIImage * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        fulfill([self imageWithContentsOfFile:path]);
    }];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

@end
