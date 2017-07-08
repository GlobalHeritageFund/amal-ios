//
//  LocalPhoto.h
//  Amal
//
//  Created by Dustin Dettmer on 5/24/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promise.h"

@class AMLMetadata;

@interface LocalPhoto : NSObject

- (instancetype)initWithImagePath:(NSString *)imagePath settingsPath:(NSString *)settingsPath;

@property (readonly) NSString *imagePath;
@property (readonly) NSString *settingsPath;
@property (readonly) NSDate *date;

@property (readonly) AMLMetadata *metadata;

@property (strong) UIImage *image;


// Write settings out to file
- (void)saveMetadata;

- (void)load:(void (^)(LocalPhoto *localPhoto))callback;

- (void)loadFullSize:(void (^)(UIImage *))callback;

- (Promise<UIImage *> *)loadFullSize;

- (void)removeLocalData;

@end
