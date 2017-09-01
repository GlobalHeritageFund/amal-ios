//
//  LocalDraftDataSource.m
//  Amal
//
//  Created by Soroush Khanlou on 8/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "LocalDraftDataSource.h"
#import "ReportDraft.h"
#import "NSArray+Additions.h"

@implementation LocalDraftDataSource

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    _reports = [[LocalDraftStorage new] read];

    return self;
}

@end

@implementation LocalDraftStorage

- (NSString *)cacheFilename {
    return @"reports/localDrafts.v1.userData";
}

- (NSString *)documentsDirectory {
    NSArray *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return searchPath.firstObject;
}

- (NSString *)dataLocation {
    return [self.documentsDirectory stringByAppendingPathComponent:self.cacheFilename];
}

- (NSArray<ReportDraft *> *)read {
    NSData *data = [NSData dataWithContentsOfFile:self.dataLocation];
    if (!data) {
        return @[];
    }
    NSArray *dictionaries = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [dictionaries arrayByTransformingObjectsUsingBlock:^id(id object) {
        return [[ReportDraft alloc] initWithDictionary:object];
    }];
}

- (void)write:(NSArray <ReportDraft *> *)reports {
    NSArray<NSDictionary *> *dictionaries = [reports arrayByTransformingObjectsUsingBlock:^id(id object) {
        return [object dictionaryRepresentation];
    }];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionaries options:0 error:nil];
    [data writeToFile:self.dataLocation atomically:YES];
}

- (void)addReportDraft:(ReportDraft *)draft {
    NSMutableArray *array = [[self read] mutableCopy];
    [array addObject:draft];
    [self write:array];
}

- (void)removeReportDraft:(ReportDraft *)draft {
    NSMutableArray *array = [[self read] mutableCopy];
    NSInteger index = [array indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [[obj localIdentifier] isEqualToString:draft.localIdentifier];
    }];
    if (index == NSNotFound) {
        return;
    }
    [array removeObjectAtIndex:index];
    [self write:array];
}

@end
