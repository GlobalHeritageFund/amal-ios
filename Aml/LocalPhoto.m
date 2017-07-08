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
    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.imagePath error:nil];
    return [fileAttribs objectForKey:NSFileCreationDate];
}

- (void)saveAndUploadMetadata {
    [self saveMetadata];
}

- (Promise<UIImage *> *)loadFullSize {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                fulfill(image);
            });
        });
    }];
}

- (Promise<LocalPhoto *> *)loadImage {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];

            UIImage *scaledImage = [image resizedImage:CGSizeFitting(image.size, CGSizeMake(400, 400)) interpolationQuality:kCGInterpolationMedium];

            dispatch_async(dispatch_get_main_queue(), ^{

                self.image = scaledImage;

                fulfill(self);
            });
        });
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

@end
