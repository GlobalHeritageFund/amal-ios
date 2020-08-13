//
//  ImageCache.h
//  Amal
//
//  Created by Soroush Khanlou on 8/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DiskCache.h"

@interface ImageCache : NSObject

+ (NSCache *)memoryCache;

+ (DiskCache *)diskCache;

@end
