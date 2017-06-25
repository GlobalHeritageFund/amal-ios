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

+ (instancetype)shared {
    static PhotoSettings *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [PhotoSettings new];
    });
    
    return instance;
}

- (NSArray*)relevantKeys {
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

- (NSDictionary*)settingsDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    for(NSString *key in self.relevantKeys) {
        
        id obj = [self valueForKey:key];
        
        if(obj)
            dict[key] = obj;
    }
    
    return dict;
}

- (void)clearSettings {
    for(NSString *key in self.relevantKeys)
        [self setValue:nil forKey:key];
}

@end

