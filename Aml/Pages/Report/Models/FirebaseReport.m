//
//  FirebaseReport.m
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "FirebaseReport.h"
#import "AMLMetadata.h"
#import "NSArray+Additions.h"
#import "Firebase.h"
#import "Firebase+Promises.h"
#import "UIImage+Resize.h"
#import "CGGeometry.h"
#import "ImageCache.h"

@implementation RemotePhoto

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    _remoteStorageLocation = dictionary[@"imageRef"];
    _metadata = [[AMLMetadata alloc] initWithDictionary:dictionary[@"settings"]];

    return self;
}

- (NSCache *)memoryCache {
    return [ImageCache memoryCache];
}

- (DiskCache *)diskCache {
    return [ImageCache diskCache];
}

- (Promise<UIImage *> *)loadThumbnailImage {
    UIImage *cachedValue = [self.memoryCache objectForKey:self.remoteStorageLocation] ?: [self.diskCache imageForKey:self.remoteStorageLocation];
    if (cachedValue) {
        return [Promise fulfilled:cachedValue];
    }

    return [[[self loadFullSizeImage] then:^id _Nullable(UIImage * _Nonnull image) {
        return [image resizedImage:CGSizeFitting(image.size, CGSizeMake(100, 100)) interpolationQuality:kCGInterpolationMedium];
    }] then:^id _Nullable(id  _Nonnull object) {
        [self.memoryCache setObject:object forKey:self.remoteStorageLocation];
        [self.diskCache setImage:object forKey:self.remoteStorageLocation];
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

@implementation FirebaseReport

- (instancetype)initWithKey:(NSString *)key dictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    _firebaseID = [key copy];
    _title = dictionary[@"title"];
    _creationDate = [[NSDate alloc] initWithTimeIntervalSince1970:[dictionary[@"creationDate"] doubleValue]];
    _uploadComplete = [dictionary[@"uploadComplete"] boolValue];
    _assessorEmail = dictionary[@"assessorEmail"];

    NSDictionary *images = dictionary[@"images"];
    _photos = [images.allKeys arrayByTransformingObjectsUsingBlock:^id(id object) {
        return [[RemotePhoto alloc] initWithDictionary:images[object]];
    }];
    
    _databaseTarget = DatabaseTargetAmal;

    return self;
}

- (Promise *)pdfURL {
    FIRStorageReference * reference = [[[[FIRStorage storage] reference] child:@"pdfs"] child:[self.firebaseID stringByAppendingPathExtension:@"pdf"]];
    return [[Promise alloc] initWithWorkQueue:dispatch_get_main_queue() work:^(void (^ _Nonnull fulfill)(NSURL * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        [reference downloadURLWithCompletion:^(NSURL * _Nullable URL, NSError * _Nullable error) {
            if (error) {
                reject(error);
            } else {
                fulfill(URL);
            }
        }];
    }];
}

- (NSInteger)photoCount {
    return self.photos.count;
}

- (BOOL)isEditable {
    return NO;
}

- (NSString *)email {
    if (self.assessorEmail.length) {
        return self.assessorEmail;
    } else {
        return NSLocalizedString(@"No email set.", @"");
    }
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
    return NSLocalizedString(@"Published", @"");
}

- (UIColor *)reportStateColor {
    return [UIColor blackColor];
}

- (NSString *)uploadState {
    return NSLocalizedString(@"Uploaded", @"");
}

- (BOOL)showProgressBars {
    return NO;
}

- (BOOL)hasPrefilledEmail {
    return NO;
}

- (ReportDraft *)draft {
    return nil;
}

@end
