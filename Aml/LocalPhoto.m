//
//  LocalPhoto.m
//  Amal
//
//  Created by Dustin Dettmer on 5/24/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "LocalPhoto.h"
#import "Firebase.h"
#import "UIImage+Resize.h"
#import "CGGeometry.h"
#import "AMLMetadata.h"
#import "UIImage+Additions.h"
#import "NSObject+Helpers.h"

@implementation LocalPhoto

- (instancetype)initWithImagePath:(NSString *)imagePath settingsPath:(NSString *)settingsPath {
    self = [super init];
    if (!self) return nil;

    _imagePath = imagePath;
    _settingsPath = settingsPath;

    NSData *data = [NSData dataWithContentsOfFile:self.settingsPath];
    if (data) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        _metadata = [[AMLMetadata alloc] initWithDictionary:dictionary];
    } else {
        _metadata = [AMLMetadata new];
    }

    return self;
}

- (NSDate *)date {
    if (self.metadata.date.timeIntervalSince1970 < 100) {
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.imagePath error:nil];
        NSDate *date = [fileAttribs objectForKey:NSFileCreationDate];
        self.metadata.date = date;
    }
    return self.metadata.date;
}

- (void)saveAndUploadMetadata {
    [self saveMetadata];
}

- (Promise<UIImage *> *)loadFullSize {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        fulfill(image);
    }];
}

- (Promise *)loadImage {
    return [[[UIImage promisedImageWithContentsOfFile:self.imagePath]
             then:^id _Nullable(UIImage *_Nonnull image) {
                 return [image resizedImage:CGSizeFitting(image.size, CGSizeMake(400, 400)) interpolationQuality:kCGInterpolationMedium];
             }] then:^id _Nullable(id  _Nonnull image) {
                 self.image = image;
                 return self;
             }];
}

- (void)saveMetadata {
    NSData *settingsData = [NSJSONSerialization dataWithJSONObject:self.metadata.dictionaryRepresentation options:0 error:nil];
    
    [settingsData writeToFile:self.settingsPath atomically:NO];
}

- (void)removeLocalData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.settingsPath error:nil];
    [fileManager removeItemAtPath:self.imagePath error:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSString *imagePath = [dictionary[@"imagePath"] asClassOrNil:[NSString class]] ?: @"";
    NSString *settingsPath = [dictionary[@"settingsPath"] asClassOrNil:[NSString class]] ?: @"";
    return [self initWithImagePath:imagePath settingsPath:settingsPath];
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
             @"imagePath": self.imagePath,
             @"settingsPath": self.settingsPath,
             };
}


@end
