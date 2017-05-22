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

@implementation LocalPhoto

- (void)load:(void (^)(LocalPhoto *))callback
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        
        NSData *data = [NSData dataWithContentsOfFile:self.settingsPath];
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            self.image = image;
            
            if(data)
                self.settings = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            else
                self.settings = nil;
            
            if(callback)
                callback(self);
        }];
    }];
}

static NSString *FirebaseImageKey = @"FirebaseImageKey";

- (NSString *)firebaseKey
{
    return self.settings[FirebaseImageKey];
}

- (void)unsync
{
    if(self.firebaseKey) {
        
        FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"images"];
        
        [ref setValue:nil forKey:self.firebaseKey];
    }
    
    NSMutableDictionary *dict = [self.settings mutableCopy];
    
    [dict removeObjectForKey:FirebaseImageKey];
    
    self.settings = dict;
}

- (void)saveSettings
{
    NSData *settingsData = [NSJSONSerialization dataWithJSONObject:self.settings ?: @{} options:0 error:nil];
    
    [settingsData writeToFile:self.settingsPath atomically:NO];
}

- (void)upload
{
    NSData *imageData = UIImageJPEGRepresentation(self.image, 0.9);
    
    FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"images"];
    
    NSString *key = self.firebaseKey;
    
    if(key) {
        
        ref = [ref child:key];
    }
    else {
        
        ref = [ref childByAutoId];
        
        NSMutableDictionary *dict = [self.settings ?: @{} mutableCopy];
        
        dict[FirebaseImageKey] = ref.key;
        
        [self saveSettings];
    }
    
    if(self.settings) {
        
        [[ref child:@"settings"] setValue:self.settings withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
            
            if(error)
                NSLog(@"Saving image settings error: %@", error);
        }];
    }
    
    FIRStorageReference *imageRef = [[[[FIRStorage storage] reference] child:@"images"] child:ref.key];
    
    [[ref child:@"imageRef"] setValue:imageRef.fullPath withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        
        if(error)
            NSLog(@"Setting imageRef error: %@", error);
    }];
    
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    
    metadata.contentType = @"image/jpeg";
    
    [imageRef putData:imageData metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
        
        if(error)
            NSLog(@"Image upload error was: %@", error);
    }];
}

@end
