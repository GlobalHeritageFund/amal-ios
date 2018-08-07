//
//  UIImage+UIImage_Resize.h
//  Amal
//
//  Created by Soroush Khanlou on 6/11/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promise.h"

@interface UIImage (Resize)

- (Promise<UIImage *> *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)synchronousResizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;

@end
