//
//  PhotoSettings.h
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalPhoto;

@interface PhotoSettings : NSObject

+ (instancetype)shared;

// Saves the jpeg data locally, using the default photo settings.
- (LocalPhoto*)saveJpegLocally:(NSData*)jpegData;

// This return an array of LocalPhotos that need 'load:' called individually.
- (NSArray*)localPhotos;

@property (strong) NSNumber *category; // int
@property (strong) NSNumber *condition; // int
@property (strong) NSNumber *levelOfDamage; // float
@property (strong) NSNumber *hazards; // bool
@property (strong) NSNumber *safetyHazards; // bool
@property (strong) NSNumber *intervention; // bool
@property (strong) NSString *notes;

@property (strong) NSNumber *lat;
@property (strong) NSNumber *lon;

- (void)clearSettings;

@end
