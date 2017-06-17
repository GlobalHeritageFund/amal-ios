//
//  PhotoSettings.m
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "PhotoSettings.h"
#import "Firebase.h"
#import "LocalPhoto.h"
#import "NSArray+Additions.h"

@implementation PhotoSettings

+ (instancetype)shared
{
    static PhotoSettings *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [PhotoSettings new];
    });
    
    return instance;
}

- (NSArray*)relevantKeys
{
    return
    @[
      @"category",
      @"condition",
      @"levelOfDamage",
      @"hazards",
      @"safetyHazards",
      @"intervention",
      @"notes",
      @"lat",
      @"lon",
      ];
}

- (NSDictionary*)settingsDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for(NSString *key in self.relevantKeys) {
        
        id obj = [self valueForKey:key];
        
        if(obj)
            dict[key] = obj;
    }
    
    return dict;
}

- (NSURL*)imagesDirectory
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    url = [url URLByAppendingPathComponent:@"images"];
    
    [NSFileManager.defaultManager createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:nil];
    
    return url;
}

- (NSArray *)localPhotos
{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *root = [NSString stringWithFormat:@"%s", self.imagesDirectory.fileSystemRepresentation];
    NSArray<NSString *> *values = [fileManager contentsOfDirectoryAtPath:root error:nil];

    NSArray<NSString *> *imageFilenames = [values arrayBySelectingObjectsPassingTest:^BOOL(id object) {
        return [[object pathExtension] isEqualToString:@"jpeg"] || [[object pathExtension] isEqualToString:@"jpg"];
    }];

    return [imageFilenames arrayByTransformingObjectsUsingBlock:^id(NSString *imageFilename) {
        LocalPhoto *localPhoto = [LocalPhoto new];

        NSString *settingsFilename = [imageFilename stringByReplacingOccurrencesOfString:imageFilename.pathExtension withString:@"json" options:0 range:NSMakeRange(0, imageFilename.length)];

        localPhoto.imagePath = [root stringByAppendingPathComponent:imageFilename];
        localPhoto.settingsPath = [root stringByAppendingPathComponent:settingsFilename];

        return localPhoto;
    }];
}

- (LocalPhoto*)saveJpegLocally:(NSData*)jpegData
{

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

    NSDictionary *settings = [self.settingsDictionary copy];
    
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

- (void)clearSettings
{
    for(NSString *key in self.relevantKeys)
        [self setValue:nil forKey:key];
}

@end
