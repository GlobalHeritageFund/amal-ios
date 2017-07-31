//
//  ReportUpload.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"

@class ReportDraft;

@interface ReportUpload : NSObject

@property (nonatomic, readonly) ReportDraft *report;

@property (nonatomic, readonly) Promise<ReportDraft *> *promise;

@property (nonatomic, readonly) NSArray<NSProgress *> *progresses;


- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft;

- (void)upload;

@end
