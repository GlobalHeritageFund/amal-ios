//
//  PhotoSettings.m
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "PhotoSettings.h"
#import "Firebase.h"

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

- (void)savePhoto:(UIImage *)image
{
    [self savePhotoData:UIImageJPEGRepresentation(image, 0.9)];
}

- (NSURL*)imagesDirectory
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    url = [url URLByAppendingPathComponent:@"images"];
    
    [NSFileManager.defaultManager createDirectoryAtURL:url withIntermediateDirectories:NO attributes:nil error:nil];
    
    return url;
}

- (void)saveJpegLocally:(NSData*)jpegData settings:(NSDictionary*)settings
{
    int i = -1;
    
    NSString *filename;
    NSString *settingsFilename;
    
    do {
        
        i++;
        
        filename = [NSString stringWithFormat:@"%s/%d.jpeg", self.imagesDirectory.fileSystemRepresentation, i];
    }
    while ([NSFileManager.defaultManager fileExistsAtPath:filename]);
    
    settingsFilename = [NSString stringWithFormat:@"%s/%d.json", self.imagesDirectory.fileSystemRepresentation, i];
    
    [jpegData writeToFile:filename atomically:NO];
    
    NSData *settingsData = [NSJSONSerialization dataWithJSONObject:settings options:0 error:nil];
    
    [settingsData writeToFile:settingsFilename atomically:NO];
}

- (void)savePhotoData:(NSData *)imageData
{
    [self saveJpegLocally:imageData settings:self.settingsDictionary];
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    ref = [[ref child:@"images"] childByAutoId];
    
    [[ref child:@"settings"] setValue:self.settingsDictionary withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if(error)
        NSLog(@"Saving image settings error: %@", error);
    }];
    
    FIRStorageReference *imageRef = [[[[FIRStorage storage] reference] child:@"images"] child:ref.key];
    
    [[ref child:@"imageRef"] setValue:imageRef.fullPath withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        if(error)
            NSLog(@"Setting imageRef error: %@", error);
    }];
    
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    
    metadata.contentType = @"image/jpeg";
    
    [imageRef putData:imageData metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
        
        if(error)
            NSLog(@"Image upload error was: %@", error);
    }];
}

- (void)clearSettings
{
    for(NSString *key in self.relevantKeys)
        [self setValue:nil forKey:key];
}

@end
