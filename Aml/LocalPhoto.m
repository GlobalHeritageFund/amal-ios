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

@end
