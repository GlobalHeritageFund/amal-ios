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
#import "AMLMetadata.h"

@implementation PhotoSettings

+ (instancetype)shared {
    static PhotoSettings *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [PhotoSettings new];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    _currentMetadata = [AMLMetadata new];

    return self;
}


@end

