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

- (void)savePhoto:(UIImage*)image;
- (void)savePhotoData:(NSData*)image;

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
@property (strong) NSString *setingsPath;

@property (strong) UIImage *image;
@property (strong) NSDictionary *settings;

- (void)load:(void (^)(LocalPhoto *localPhoto))callback;

@end
