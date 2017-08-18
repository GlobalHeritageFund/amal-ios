//
//  Report.m
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportDraft.h"

@implementation ReportDraft

- (instancetype)initWithPhotos:(NSArray<LocalPhoto *> *)photos {
    self = [super init];
    if (!self) return nil;

    _photos = [photos mutableCopy];

    _creationDate = [[NSDate alloc] init];

    return self;
}


@end
