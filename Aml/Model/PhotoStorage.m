//
//  PhotoStorage.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "PhotoStorage.h"
#import "NSArray+Additions.h"
#import "LocalPhoto.h"
#import "AMLMetadata.h"
#import "UIImage+Resize.h"

@implementation PhotoSection

@end

@implementation PhotoStorage

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"d MMM - H:mm";
    }
    return dateFormatter;
}

- (NSURL*)imagesDirectory {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    url = [url URLByAppendingPathComponent:@"images"];

    [NSFileManager.defaultManager createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:nil];

    return url;
}

- (NSArray<LocalPhoto *> *)fetchPhotos {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *root = [NSString stringWithFormat:@"%s", self.imagesDirectory.fileSystemRepresentation];
    NSArray<NSString *> *values = [fileManager contentsOfDirectoryAtPath:root error:nil];

    NSArray<NSString *> *imageFilenames = [values arrayBySelectingObjectsPassingTest:^BOOL(id object) {
        return [[object pathExtension] isEqualToString:@"jpeg"] || [[object pathExtension] isEqualToString:@"jpg"];
    }];

    NSArray<LocalPhoto *> *localPhotos = [imageFilenames arrayByTransformingObjectsUsingBlock:^id(NSString *imageFilename) {

        NSString *settingsFilename = [imageFilename stringByReplacingOccurrencesOfString:imageFilename.pathExtension withString:@"json" options:0 range:NSMakeRange(0, imageFilename.length)];

        NSString *imagePath = [root stringByAppendingPathComponent:imageFilename];
        NSString *settingsPath = [root stringByAppendingPathComponent:settingsFilename];

        return [[LocalPhoto alloc] initWithImagePath:imagePath settingsPath:settingsPath];
;
    }];

    return [localPhotos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
}

- (NSArray<PhotoSection *> *)fetchGroupedPhotos {
    return [self fetchGroupedPhotosWithFilter:[DefaultPhotoFilter new]];
}

- (NSArray<PhotoSection *> *)fetchGroupedPhotosWithFilter:(id<LocalPhotoFilter>)filter {
    NSArray<LocalPhoto *> *photos = [[self fetchPhotos] arrayBySelectingObjectsPassingTest:^BOOL(LocalPhoto *photo) {
        return [filter shouldIncludePhoto:photo];
    }];

    NSMutableArray<PhotoSection *> *sections = [NSMutableArray new];

    NSMutableArray<LocalPhoto *> *photosForCurrentSection = [NSMutableArray new];
    for (LocalPhoto *photo in photos) {
        if (photosForCurrentSection.count == 0) {
            [photosForCurrentSection addObject:photo];
            continue;
        }

        if ([photosForCurrentSection.lastObject.date timeIntervalSinceDate:photo.date] > 60*60) {
            PhotoSection *section = [[PhotoSection alloc] init];
            section.header = [self.dateFormatter stringFromDate:photosForCurrentSection.firstObject.date];
            section.photos = photosForCurrentSection;
            [sections addObject:section];
            photosForCurrentSection = [NSMutableArray new];
            [photosForCurrentSection addObject:photo];
        } else {
            [photosForCurrentSection addObject:photo];
        }
    }
    if (photosForCurrentSection.count != 0) {
        PhotoSection *section = [[PhotoSection alloc] init];
        section.header = [self.dateFormatter stringFromDate:photosForCurrentSection.firstObject.date];
        section.photos = photosForCurrentSection;
        [sections addObject:section];
    }
    return sections;
}


- (LocalPhoto*)saveJpegLocally:(NSData*)jpegData withMetadata:(AMLMetadata *)metadata {

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

    UIImage *image = [UIImage imageWithData:jpegData];
    UIImage *normalizedImage = [image synchronousResizedImage:image.size interpolationQuality:kCGInterpolationHigh];
    NSData *normalizedImageData = UIImageJPEGRepresentation(normalizedImage, 0.9);
    
    [normalizedImageData writeToFile:filename atomically:YES];

    NSData *settingsData = [NSJSONSerialization dataWithJSONObject:metadata.dictionaryRepresentation options:0 error:nil];

    [settingsData writeToFile:settingsFilename atomically:YES];

    LocalPhoto *localPhoto = [[LocalPhoto alloc] initWithImagePath:filename settingsPath:settingsFilename];
    
    return localPhoto;
}

@end