//
//  LocalPhoto.h
//  Amal
//
//  Created by Dustin Dettmer on 5/24/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalPhoto : NSObject

@property (strong) NSString *imagePath;
@property (strong) NSString *settingsPath;
@property (readonly) NSDate *date;


@property (strong) UIImage *image;
@property (strong) NSDictionary *settings;

- (void)setSettingsValue:(id)value forKey:(NSString*)key;

// Reads the firebase key from 'settings' dictionary.
@property (readonly) NSString *firebaseKey;

// Removes the firebaseKey from the settings dictionary and deletes the
// image from the server.
- (void)unsync;

// Write settings out to file
- (void)saveSettings;

- (void)load:(void (^)(LocalPhoto *localPhoto))callback;

// Called automatically when calling setSettingsValue.
- (void)uploadSettingsIfHasKey;

// If 'firebaseKey' is nil, one will be generated and added to 'settings'.
// This will trigger a 'saveSettings' event.
- (void)uploadEverything;

- (void)removeLocalData;

@end
