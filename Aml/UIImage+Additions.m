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

@end
