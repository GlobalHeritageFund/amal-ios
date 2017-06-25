//
//  PhotoStorage.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "PhotoStorage.h"
#import "NSArray+Additions.h"
#import "LocalPhoto.h"

@implementation PhotoStorage

- (NSURL*)imagesDirectory {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    url = [url URLByAppendingPathComponent:@"images"];

    [NSFileManager.defaultManager createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:nil];

    return url;
}

- (NSArray*)fetchPhotos {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *root = [NSString stringWithFormat:@"%s", self.imagesDirectory.fileSystemRepresentation];
    NSArray<NSString *> *values = [fileManager contentsOfDirectoryAtPath:root error:nil];

    NSArray<NSString *> *imageFilenames = [values arrayBySelectingObjectsPassingTest:^BOOL(id object) {
        return [[object pathExtension] isEqualToString:@"jpeg"] || [[object pathExtension] isEqualToString:@"jpg"];
    }];

    NSArray<LocalPhoto *> *localPhotos = [imageFilenames arrayByTransformingObjectsUsingBlock:^id(NSString *imageFilename) {
        LocalPhoto *localPhoto = [LocalPhoto new];

        NSString *settingsFilename = [imageFilename stringByReplacingOccurrencesOfString:imageFilename.pathExtension withString:@"json" options:0 range:NSMakeRange(0, imageFilename.length)];

        localPhoto.imagePath = [root stringByAppendingPathComponent:imageFilename];
        localPhoto.settingsPath = [root stringByAppendingPathComponent:settingsFilename];

        return localPhoto;
    }];

    return [localPhotos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
}

- (LocalPhoto*)saveJpegLocally:(NSData*)jpegData withSettings:(NSDictionary *)settings {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *root = [NSString stringWithFormat:@"%s", self.imagesDirectory.fileSystemRepresentation];
    NSArray<NSString *> *values = [fileManager contentsOfDirectoryAtPath:root error:nil];

    NSArray<NSString *> *imageFilenames = [values arrayBySelectingObjectsPassingTest:^BOOL(id object) {
        return [[object pathExtension] isEqualToString:@"jpeg"] || [[object pathExtension] isEqualToString:@"jpg"];
    }];

    NSArray<NSNumber *> *imageIDs = [imageFilenames arrayByTransformingObjectsUsingBlock:^id(id object) {
        return @([[object stringByDeletingPathExtension] intValue]);
    }];

    NSNumber *maxNumber = [imageIDs valueForKeyPath:@"@max.intValue"];
    NSNumber *newNumber = @(maxNumber.intValue+1);

    NSString *settingsFilename = [NSString stringWithFormat:@"%s/%@.json", self.imagesDirectory.fileSystemRepresentation, newNumber];
    NSString *filename = [NSString stringWithFormat:@"%s/%@.jpeg", self.imagesDirectory.fileSystemRepresentation, newNumber];

    [jpegData writeToFile:filename atomically:NO];

    NSData *settingsData = [NSJSONSerialization dataWithJSONObject:settings options:0 error:nil];

    [settingsData writeToFile:settingsFilename atomically:NO];

    LocalPhoto *localPhoto = [LocalPhoto new];

    localPhoto.imagePath = filename;
    localPhoto.settingsPath = settingsFilename;
    
    localPhoto.settings = settings;
    
    return localPhoto;
}


@end
