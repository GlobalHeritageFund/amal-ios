//
//  Report.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalPhoto;

@interface ReportDraft : NSObject

- (instancetype)initWithPhotos:(NSArray<LocalPhoto *> *)photos;

@property (nonatomic) NSString *title;
@property (nonatomic) NSString *deviceToken;
@property (readonly) NSDate *creationDate;

@property (nonatomic) NSMutableArray<LocalPhoto *> *photos;

- (void)addPhoto:(LocalPhoto *)photo;

@end
