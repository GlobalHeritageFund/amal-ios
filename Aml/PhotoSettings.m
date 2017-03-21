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

- (void)savePhotoData:(NSData *)imageData
{
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    ref = [[ref child:@"images"] childByAutoId];
    
    [[ref child:@"settings"] setValue:self.settingsDictionary];
    
    NSString *imageDataStr = [imageData base64EncodedStringWithOptions:0];
    
    [[ref child:@"imageData"] setValue:imageDataStr withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
        NSLog(@"ref is: %@", ref);
        NSLog(@"error is: %@", error);
        NSLog(@"FIN");
    }];
}

- (void)clearSettings
{
    for(NSString *key in self.relevantKeys)
        [self setValue:nil forKey:key];
}

@end
