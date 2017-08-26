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

@implementation RemotePhoto

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    _remoteStorageLocation = dictionary[@"imageRef"];
    _metadata = [[AMLMetadata alloc] initWithDictionary:dictionary[@"settings"]];

    return self;
}

- (Promise<UIImage *> *)loadThumbnailImage {
    return [[[self loadFullSizeImage] then:^id _Nullable(UIImage * _Nonnull image) {
        return [image resizedImage:CGSizeFitting(image.size, CGSizeMake(100, 100)) interpolationQuality:kCGInterpolationMedium];
    }] then:^id _Nullable(id  _Nonnull object) {
        self.image = object;
        return nil;
    }];
}

- (Promise<UIImage *> *)loadFullSizeImage {
    Promise<NSData *> *promise = [[[FIRStorage storage] referenceWithPath:self.remoteStorageLocation] dataWithMaxSize:INT64_MAX];
    return (Promise<UIImage *> *)[promise then:^id _Nullable(id  _Nonnull data) {
        return [UIImage imageWithData:data];
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
    _photos = [images.allKeys arrayByTransformingObjectsUsingBlock:^id(id object) {
        return [[RemotePhoto alloc] initWithDictionary:images[object]];
    }];

    return self;
}

- (NSInteger)photoCount {
    return self.photos.count;
}

- (BOOL)isEditable {
    return NO;
}

- (NSDate *)minDate {
    return [self.photos valueForKeyPath:@"@min.metadata.date"];
}

- (NSDate *)maxDate {
    return [self.photos valueForKeyPath:@"@max.metadata.date"];
}

- (NSProgress *)progress {
    return [[NSProgress alloc] init];
}

- (NSString *)reportState {
    return @"Published";
}

- (UIColor *)reportStateColor {
    return [UIColor blackColor];
}

- (NSString *)uploadState {
    return @"Uploaded";
}

@end
