//
//  DiskCache.m
//  Amal
//
//  Created by Soroush Khanlou on 5/13/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "DiskCache.h"
#import "NSString+Additions.h"

@interface DiskCache()

@property NSURL *location;

@end

@implementation DiskCache

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (!self) return nil;

    NSURL *cachesDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];

    self.location = [cachesDirectory URLByAppendingPathComponent:name];

    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    NSData *data = UIImageJPEGRepresentation(image, 0.9);

    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:self.location.relativePath withIntermediateDirectories:YES attributes:nil error:&error];

    NSURL *url = [self.location URLByAppendingPathComponent:[[key md5] stringByAppendingPathExtension:@"cache"]];

    [data writeToURL:url options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

- (UIImage *)imageForKey:(NSString *)key {
    NSURL *url = [self.location URLByAppendingPathComponent:[[key md5] stringByAppendingPathExtension:@"cache"]];

    NSData *imageData = [[NSData alloc] initWithContentsOfURL:url];

    if (imageData == nil) {
        return nil;
    }

    return [UIImage imageWithData:imageData];
}

- (void)resetCache {
    [[NSFileManager defaultManager] removeItemAtPath:self.location.relativePath error:nil];
}

@end
