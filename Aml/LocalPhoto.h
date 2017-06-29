//
//  LocalPhoto.h
//  Amal
//
//  Created by Dustin Dettmer on 5/24/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMLMetadata;

@interface LocalPhoto : NSObject

- (instancetype)initWithImagePath:(NSString *)imagePath settingsPath:(NSString *)settingsPath;

@property (readonly) NSString *imagePath;
@property (readonly) NSString *settingsPath;
@property (readonly) NSDate *date;

@property (readonly) AMLMetadata *metadata;

@property (strong) UIImage *image;

// Reads the firebase key from 'settings' dictionary.
@property (readonly) NSString *firebaseKey;

// Removes the firebaseKey from the settings dictionary and deletes the
// image from the server.
- (void)unsync;

// Write settings out to file
- (void)saveSettings;

- (void)load:(void (^)(LocalPhoto *localPhoto))callback;

- (void)loadFullSize:(void (^)(UIImage *))callback;

// Called automatically when calling setSettingsValue.
- (void)uploadSettingsIfHasKey;

// If 'firebaseKey' is nil, one will be generated and added to 'settings'.
// This will trigger a 'saveSettings' event.
- (void)uploadEverything;

- (void)removeLocalData;

@end
