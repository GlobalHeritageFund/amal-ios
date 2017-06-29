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

    [self uploadSettingsIfHasKey];
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

- (NSString *)firebaseKey {
    return self.metadata.firebaseImageKey;
}

- (void)unsync {
    if(self.firebaseKey) {
        
        FIRDatabaseReference *ref = [[[[FIRDatabase database] reference] child:@"images"] child:self.firebaseKey];
        
        [ref removeValue];
    }

    self.metadata.firebaseImageKey = nil;
}

- (void)saveMetadata {
    NSData *settingsData = [NSJSONSerialization dataWithJSONObject:self.metadata.dictionaryRepresentation options:0 error:nil];
    
    [settingsData writeToFile:self.settingsPath atomically:NO];
}

- (FIRDatabaseReference*)getOrMakeFirebaseRef {
    FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"images"];
    
    NSString *key = self.firebaseKey;
    
    if(key) {
        
        ref = [ref child:key];
    }
    else {
        
        ref = [ref childByAutoId];

        self.metadata.firebaseImageKey = ref.key;

        [self saveMetadata];
    }
    
    return ref;
}

- (void)uploadSettingsIfHasKey
{
    if(!self.firebaseKey)
        return;
    
    FIRDatabaseReference *ref = [self getOrMakeFirebaseRef];

        [[ref child:@"settings"] setValue:self.metadata.dictionaryRepresentation];
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
