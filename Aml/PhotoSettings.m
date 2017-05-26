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
    NSMutableArray *array = [NSMutableArray new];
    
    for(int i = 0;; i++) {
        
        NSString *filename = [NSString stringWithFormat:@"%s/%d.jpeg", self.imagesDirectory.fileSystemRepresentation, i];
    
        if(![NSFileManager.defaultManager fileExistsAtPath:filename])
            break;
        
        LocalPhoto *localPhoto = [LocalPhoto new];
        
        localPhoto.imagePath = filename;
        localPhoto.settingsPath = [NSString stringWithFormat:@"%s/%d.json", self.imagesDirectory.fileSystemRepresentation, i];
        
        [array addObject:localPhoto];
    }
    
    return array;
}

- (LocalPhoto*)saveJpegLocally:(NSData*)jpegData
{
    int i = -1;
    
    NSString *filename;
    NSString *settingsFilename;
    
    do {
        
        i++;
        
        filename = [NSString stringWithFormat:@"%s/%d.jpeg", self.imagesDirectory.fileSystemRepresentation, i];
    }
    while ([NSFileManager.defaultManager fileExistsAtPath:filename]);
    
    NSDictionary *settings = [self.settingsDictionary copy];
    
    settingsFilename = [NSString stringWithFormat:@"%s/%d.json", self.imagesDirectory.fileSystemRepresentation, i];
    
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
