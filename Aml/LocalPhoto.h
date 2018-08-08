//
//  LocalPhoto.h
//  Amal
//
//  Created by Dustin Dettmer on 5/24/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promise.h"
#import "ReportProtocols.h"

@class AMLMetadata;

@interface LocalPhoto : NSObject<PhotoProtocol>

- (instancetype)initWithImagePath:(NSString *)imagePath settingsPath:(NSString *)settingsPath;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (readonly) NSString *imagePath;
@property (readonly) NSString *settingsPath;
@property (readonly) NSDate *date;

@property (readonly) AMLMetadata *metadata;

- (void)saveMetadata;

- (void)refreshMetadata;

- (Promise<UIImage *> *)loadThumbnailImage;

- (Promise<UIImage *> *)loadFullSizeImage;

- (Promise<UIImage *> *)loadCorrectlyOrientedFullSizeImage;

- (void)removeLocalData;

@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;

@end
