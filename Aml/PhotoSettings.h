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

- (void)clearSettings;

@end

@interface LocalPhoto : NSObject

@property (strong) NSString *imagePath;
@property (strong) NSString *settingsPath;

@property (strong) UIImage *image;
@property (strong) NSDictionary *settings;

// Reads the firebase key from 'settings' dictionary.
@property (readonly) NSString *firebaseKey;

// Removes the firebaseKey from the settings dictionary and deletes the
// image from the server.
- (void)unsync;

// Write settings out to file
- (void)saveSettings;

- (void)load:(void (^)(LocalPhoto *localPhoto))callback;

// If 'firebaseKey' is nil, one will be generated and added to 'settings'.
// This will trigger a 'saveSettings' event.
- (void)upload;

@end
