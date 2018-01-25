//
//  Report.h
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"
#import <UIKit/UIKit.h>
#import "ReportViewModel.h"

@class AMLMetadata;

@interface RemotePhoto : NSObject <PhotoProtocol>

@property (nonatomic, readonly) AMLMetadata *metadata;
@property (nonatomic) NSString *remoteStorageLocation;

- (Promise<UIImage *> *)loadThumbnailImage;
- (Promise<UIImage *> *)loadFullSizeImage;

@property (nonatomic) UIImage *image;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end


@interface Report : NSObject<ReportProtocol>

@property (readonly) NSString *firebaseID;
@property (readonly) NSString *title;
@property (readonly) NSString *assessorEmail;
@property (readonly) NSDate *creationDate;
@property (nonatomic) BOOL uploadComplete;


@property (nonatomic, readonly) NSArray<RemotePhoto *> *photos;

- (instancetype)initWithKey:(NSString *)key dictionary:(NSDictionary *)dictionary;
@end

