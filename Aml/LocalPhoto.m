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

- (void)loadFullSize:(void (^)(UIImage *))callback {
    NSParameterAssert(callback != nil);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image);
        });
    });
}

- (void)load:(void (^)(LocalPhoto *))callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        
        UIImage *scaledImage = [image resizedImage:CGSizeFitting(image.size, CGSizeMake(400, 400)) interpolationQuality:kCGInterpolationMedium];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            self.image = scaledImage;

            if(callback) {
                callback(self);
            }
        });
    });
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
