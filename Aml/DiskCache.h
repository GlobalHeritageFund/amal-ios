//
//  DiskCache.h
//  Amal
//
//  Created by Soroush Khanlou on 5/13/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DiskCache : NSObject

- (instancetype)initWithName:(NSString *)name;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;

- (UIImage *)imageForKey:(NSString *)key;

@end
