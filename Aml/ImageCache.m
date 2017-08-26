//
//  ImageCache.m
//  Amal
//
//  Created by Soroush Khanlou on 8/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

+ (NSCache *)cache {
    static NSCache *cache;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        cache = [NSCache new];
    });

    return cache;
}

@end
