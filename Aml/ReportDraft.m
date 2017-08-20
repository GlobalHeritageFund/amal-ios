//
//  Report.m
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportDraft.h"
#import "LocalPhoto.h"

@implementation ReportDraft

- (instancetype)initWithPhotos:(NSArray<LocalPhoto *> *)photos {
    self = [super init];
    if (!self) return nil;

    _photos = [photos mutableCopy];

    _creationDate = [[NSDate alloc] init];

    return self;
}

- (void)addPhoto:(LocalPhoto *)photo {
    NSUInteger i = [self.photos indexOfObjectPassingTest:^BOOL(LocalPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.imagePath isEqual:photo.imagePath];
    }];
    if (i == NSNotFound) {
        [self.photos addObject:photo];
    }
}

@end
