//
//  Report.m
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportDraft.h"
#import "LocalPhoto.h"
#import "NSObject+Helpers.h"
#import "NSArray+Additions.h"

@implementation ReportDraft

- (instancetype)initWithPhotos:(NSArray<LocalPhoto *> *)photos {
    self = [super init];
    if (!self) return nil;

    _localIdentifier = [[NSUUID UUID] UUIDString];

    _localPhotos = [photos mutableCopy];

    _creationDate = [[NSDate alloc] init];

    return self;
}

- (void)addPhoto:(LocalPhoto *)photo {
    NSUInteger i = [self.photos indexOfObjectPassingTest:^BOOL(LocalPhoto * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.imagePath isEqual:photo.imagePath];
    }];
    if (i == NSNotFound) {
        [self.localPhotos addObject:photo];
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    _localIdentifier = [dictionary[@"localIdentifer"] asClassOrNil:[NSString class]];
    _title = [dictionary[@"title"] asClassOrNil:[NSString class]];
    _deviceToken = [dictionary[@"deviceToken"] asClassOrNil:[NSString class]];
    _creationDate = [NSDate dateWithTimeIntervalSince1970:[[dictionary[@"creationDate"] asClassOrNil:[NSNumber class]] doubleValue]];
    _localPhotos = [[[dictionary[@"photos"] asClassOrNil:[NSArray class]] arrayByTransformingObjectsUsingBlock:^id(id object) {
        return [[LocalPhoto alloc] initWithDictionary:object];
    }] mutableCopy];

    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
             @"localIdentifier": self.localIdentifier ?: @"",
             @"title": self.title ?: [NSNull null],
             @"deviceToken": self.deviceToken ?: [NSNull null],
             @"creationDate": @([self.creationDate timeIntervalSince1970]),
             @"photos": [self.photos arrayByTransformingObjectsUsingBlock:^id(LocalPhoto *object) {
                 return object.dictionaryRepresentation;
             }],
             };
}

- (NSArray<LocalPhoto *> *)photos {
    return self.localPhotos;
}

- (NSDate *)minDate {
    return [self.photos valueForKeyPath:@"@min.date"];
}

- (NSDate *)maxDate {
    return [self.photos valueForKeyPath:@"@max.date"];
}

- (NSInteger)photoCount {
    return self.photos.count;
}

- (NSProgress *)progress {
    return [NSProgress progressWithTotalUnitCount:0];
}

- (NSString *)uploadState {
    return @"Publish Report";
}

- (NSString *)reportState {
    return @"Draft";
}

- (UIColor *)reportStateColor {
    return [UIColor redColor];
}

- (BOOL)isEditable {
    return YES;
}

@end
