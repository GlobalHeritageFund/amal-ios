//
//  ReportViewModel.h
//  Amal
//
//  Created by Soroush Khanlou on 8/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportProtocols.h"

@interface ReportViewModel : NSObject

- (instancetype)initWithReport:(id<ReportProtocol>)report;

@property (nonatomic, readonly) id<ReportProtocol> report;

@property (readonly) BOOL isEditable;
@property (readonly) NSArray<id<PhotoProtocol>> *photos;
@property (readonly) NSString *title;
@property (readonly) NSString *dateInterval;
@property (readonly) NSString *creationDateString;
@property (readonly) NSString *imageCountString;
@property (readonly) NSString *uploadState;
@property (readonly) NSString *reportState;
@property (readonly) UIColor *reportStateColor;
@property (readonly) NSProgress *progress;

@property (nonatomic, readonly) ReportDraft *draft;
@property (nonatomic, readonly) ReportUpload *upload;
@property (nonatomic, readonly) Report *finalized;

@end
