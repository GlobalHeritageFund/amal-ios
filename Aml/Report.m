//
//  Report.m
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "Report.h"
#import "AMLMetadata.h"
#import "NSArray+Additions.h"
#import "Firebase.h"
#import "Firebase+Promises.h"
#import "UIImage+Resize.h"
#import "CGGeometry.h"

@implementation Image

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    _remoteStorageLocation = dictionary[@"imageRef"];
    _settings = [[AMLMetadata alloc] initWithDictionary:dictionary[@"settings"]];

    return self;
}

- (Promise *)fetchFirebaseImage {
    return [[[[[FIRStorage storage] referenceWithPath:self.remoteStorageLocation] dataWithMaxSize:INT64_MAX] then:^id _Nullable(id  _Nonnull data) {
        return [UIImage imageWithData:data];
    }] then:^id _Nullable(UIImage * _Nonnull image) {
        return [image resizedImage:CGSizeFitting(image.size, CGSizeMake(100, 100)) interpolationQuality:kCGInterpolationMedium];
    }];
}

@end

@implementation Report

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    _title = dictionary[@"title"];
    _creationDate = [[NSDate alloc] initWithTimeIntervalSince1970:[dictionary[@"creationDate"] doubleValue]];

    NSDictionary *images = dictionary[@"images"];
    _images = [images.allKeys arrayByTransformingObjectsUsingBlock:^id(id object) {
        return [[Image alloc] initWithDictionary:images[object]];
    }];

    return self;
}

- (NSInteger)photoCount {
    return self.images.count;
}

- (BOOL)isEditable {
    return NO;
}

- (NSDate *)minDate {
    return [self.images valueForKeyPath:@"@min.settings.date"];
}

- (NSDate *)maxDate {
    return [self.images valueForKeyPath:@"@max.settings.date"];
}

- (NSProgress *)progress {
    return [[NSProgress alloc] init];
}

- (NSString *)reportState {
    return @"Published";
}

- (NSString *)uploadState {
    return @"Uploaded";
}

@end
