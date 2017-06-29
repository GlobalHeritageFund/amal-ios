//
//  LocalPhoto.m
//  Amal
//
//  Created by Dustin Dettmer on 5/24/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "LocalPhoto.h"
#import "Firebase.h"
#import "UIImage+Resize.h"
#import "CGGeometry.h"

@implementation LocalPhoto

- (NSDate *)date {
    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:self.imagePath error:nil];
    return [fileAttribs objectForKey:NSFileCreationDate];
}

- (void)setSettingsValue:(id)value forKey:(NSString *)key
{
    NSMutableDictionary *dict = [self.settings mutableCopy];
    
    dict[key] = value;
    
    self.settings = dict;
    
    [self saveSettings];
    
    [self uploadSettingsIfHasKey];
}

- (void)load:(void (^)(LocalPhoto *))callback
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        
        NSData *data = [NSData dataWithContentsOfFile:self.settingsPath];
        UIImage *image = [UIImage imageWithContentsOfFile:self.imagePath];

        UIImage *scaledImage = [image resizedImage:CGSizeFitting(image.size, CGSizeMake(400, 400)) interpolationQuality:kCGInterpolationMedium];
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            
            self.image = scaledImage;
            
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
        
        FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"images"] child:self.firebaseKey];
        
        [ref removeValue];
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

- (FIRDatabaseReference*)getOrMakeFirebaseRef
{
    FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"images"];
    
    NSString *key = self.firebaseKey;
    
    if(key) {
        
        ref = [ref child:key];
    }
    else {
        
        ref = [ref childByAutoId];
        
        NSMutableDictionary *dict = [self.settings ?: @{} mutableCopy];
        
        dict[FirebaseImageKey] = ref.key;
        
        self.settings = dict;
        
        [self saveSettings];
    }
    
    return ref;
}

- (void)uploadSettingsIfHasKey
{
    if(!self.firebaseKey)
        return;
    
    FIRDatabaseReference *ref = [self getOrMakeFirebaseRef];
    
    if(self.settings)
        [[ref child:@"settings"] setValue:self.settings];
}

- (void)uploadEverything
{
    NSData *imageData = UIImageJPEGRepresentation(self.image, 0.9);
    
    FIRDatabaseReference *ref = [self getOrMakeFirebaseRef];
    
    [self uploadSettingsIfHasKey];
    
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

- (void)removeLocalData {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.settingsPath error:nil];
    [fileManager removeItemAtPath:self.imagePath error:nil];
}

@end
