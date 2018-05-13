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
#import "ImageCache.h"
#import "PhotoStorage.h"

@implementation LocalPhoto

- (instancetype)initWithImagePath:(NSString *)imagePath settingsPath:(NSString *)settingsPath {
    self = [super init];
    if (!self) return nil;

    _imagePath = imagePath;
    _settingsPath = settingsPath;

    [self refreshMetadata];

    return self;
}

- (NSDate *)date {
    if (self.metadata.date.timeIntervalSince1970 < 100) {
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.imagePath error:nil];
        NSDate *date = [fileAttribs objectForKey:NSFileCreationDate];
        self.metadata.date = date;
        [self saveMetadata];
    }
    return self.metadata.date;
}

- (Promise<UIImage *> *)loadFullSizeImage {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        fulfill(image);
    }];
}

- (NSCache *)memoryCache {
    return [ImageCache memoryCache];
}

- (Promise<UIImage *> *)loadThumbnailImage {
    UIImage *cachedValue = [self.memoryCache objectForKey:self.imagePath];
    if (cachedValue) {
        return [Promise fulfilled:cachedValue];
    }
    return [[[UIImage promisedImageWithContentsOfFile:self.imagePath]
             then:^id _Nullable(UIImage *_Nonnull image) {
                 return [image resizedImage:CGSizeFitting(image.size, CGSizeMake(400, 400)) interpolationQuality:kCGInterpolationMedium];
             }] then:^id _Nullable(id  _Nonnull image) {
                 [self.memoryCache setObject:image forKey:self.imagePath];
                 return image;
             }];
}

- (void)saveMetadata {
    NSData *settingsData = [NSJSONSerialization dataWithJSONObject:self.metadata.dictionaryRepresentation options:0 error:nil];
    
    [settingsData writeToFile:self.settingsPath atomically:NO];
}

- (void)refreshMetadata {
    NSData *data = [NSData dataWithContentsOfFile:self.settingsPath];
    if (data) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        _metadata = [[AMLMetadata alloc] initWithDictionary:dictionary];
    } else {
        _metadata = [AMLMetadata new];
    }
}

- (void)removeLocalData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.settingsPath error:nil];
    [fileManager removeItemAtPath:self.imagePath error:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    NSString *imageFileName = [dictionary[@"imageFileName"] asClassOrNil:[NSString class]] ?: @"";
    NSString *settingsFileName = [dictionary[@"settingsFileName"] asClassOrNil:[NSString class]] ?: @"";

    PhotoStorage *photoStorage = [PhotoStorage new];
    NSString *imagesDirectory = [[photoStorage imagesDirectory] path];
    NSString *imagePath = [imagesDirectory stringByAppendingPathComponent:imageFileName];
    NSString *settingsPath = [imagesDirectory stringByAppendingPathComponent:settingsFileName];
    return [self initWithImagePath:imagePath settingsPath:settingsPath];
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
             @"imageFileName": self.imagePath.lastPathComponent,
             @"settingsFileName": self.settingsPath.lastPathComponent,
             };
}


@end
