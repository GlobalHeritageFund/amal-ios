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

@interface RemotePhoto : NSObject

@property (nonatomic, readonly) AMLMetadata *settings;
@property (nonatomic) NSString *remoteStorageLocation;

- (Promise<UIImage *> *)fetchFirebaseImage;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end


@interface Report : NSObject<ReportProtocol>

@property (readonly) NSString *title;
@property (readonly) NSDate *creationDate;

@property (nonatomic, readonly) NSArray<RemotePhoto *> *images;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, readonly) NSString *imageCountString;

@end

