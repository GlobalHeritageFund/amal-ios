//
//  ReportProtocols.h
//  Amal
//
//  Created by Soroush Khanlou on 8/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Promise.h"

@class ReportDraft, Report, ReportUpload, AMLMetadata;

@protocol PhotoProtocol

@property (readonly) AMLMetadata *metadata;

- (Promise<UIImage *> *)loadThumbnailImage;

- (Promise<UIImage *> *)loadFullSizeImage;

@end


@protocol ReportProtocol <NSObject>

@property (readonly) BOOL isEditable;

@property (readonly) BOOL hasPrefilledEmail;

@property (readonly) NSString *email;

@property (readonly) NSString *title;

@property (readonly) NSDate *minDate;

@property (readonly) NSDate *maxDate;

@property (readonly) NSArray<id<PhotoProtocol>> *photos;

@property (readonly) NSInteger photoCount;

@property (readonly) NSDate *creationDate;

@property (readonly) NSProgress *progress;

@property (readonly) UIColor *reportStateColor;

@property (readonly) NSString *reportState;

@property (readonly) NSString *uploadState;

@property (readonly) BOOL showProgressBars;

@end
