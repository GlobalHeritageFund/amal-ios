//
//  Report.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportViewModel.h"

@class LocalPhoto;

@interface ReportDraft : NSObject<ReportProtocol>

- (instancetype)initWithPhotos:(NSArray<LocalPhoto *> *)photos;

@property (readonly) NSString *localIdentifier;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *deviceToken;
@property (readonly) NSDate *creationDate;
@property (nonatomic) BOOL hasPrefilledEmail;

@property (nonatomic) BOOL isEAMENA;

@property (nonatomic) NSMutableArray<LocalPhoto *> *localPhotos;

@property (readonly) NSArray<id<PhotoProtocol>> *photos;


- (void)addPhoto:(LocalPhoto *)photo;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;
@property (nonatomic, readonly) NSDictionary *heritageDictionaryRepresentation;

@property (readonly) NSDate *minDate;

@property (readonly) NSDate *maxDate;

@property (readonly) NSString *photoCountString;

@end