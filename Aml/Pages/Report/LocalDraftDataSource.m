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

static NSString *LocalDraftDataSourceDidChange = @"LocalDraftDataSourceDidChange";

@interface LocalDraftDataSource ()

@property (nonatomic) LocalDraftStorage *storage;
@property (nonatomic) NSArray<ReportDraft *> *reports;

@end

@implementation LocalDraftDataSource

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    _storage = [LocalDraftStorage new];
    _reports = [self.storage read];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDrafts:) name:LocalDraftDataSourceDidChange object:nil];

    return self;
}

- (void)reloadDrafts:(NSNotification *)note {
    self.reports = [self.storage read];
    [self.delegate dataSourceUpdated:self];
}

- (void)postNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:LocalDraftDataSourceDidChange object:self];
}

- (void)addReportDraft:(ReportDraft *)draft {
    NSMutableArray *array = [[self.storage read] mutableCopy];
    NSInteger index = [array indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [[obj localIdentifier] isEqualToString:draft.localIdentifier];
    }];
    if (index == NSNotFound) {
        [array addObject:draft];
    } else {
        [array replaceObjectAtIndex:index withObject:draft];
    }
    [self.storage write:array];
    [self postNotification];
}

- (void)removeReportDraft:(ReportDraft *)draft {
    NSMutableArray *array = [[self.storage read] mutableCopy];
    NSInteger index = [array indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [[obj localIdentifier] isEqualToString:draft.localIdentifier];
    }];
    if (index == NSNotFound) {
        return;
    }
    [array removeObjectAtIndex:index];
    [self.storage write:array];
    [self postNotification];
}

- (BOOL)hasDrafts {
    return self.reports.count != 0;
}

@end

@implementation LocalDraftStorage

- (NSString *)cacheFilename {
    return @"localDrafts.v1.userData";
}

- (NSString *)documentsDirectory {
    NSArray *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return searchPath.firstObject;
}

- (NSString *)reportsDirectory {
    return [self.documentsDirectory stringByAppendingPathComponent:@"reports"];
}

- (NSString *)dataLocation {
    return [self.reportsDirectory stringByAppendingPathComponent:self.cacheFilename];
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
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionaries options:0 error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:self.reportsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    [data writeToFile:self.dataLocation options:NSDataWritingAtomic error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

@end
