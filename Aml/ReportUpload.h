//
//  ReportUpload.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"

@class Report;

@interface ReportUpload : NSObject

@property (nonatomic, readonly) Report *report;

@property (nonatomic, readonly) Promise<Report *> *promise;

@property (nonatomic, readonly) NSArray<NSProgress *> *progresses;


- (instancetype)initWithReport:(Report *)report;

- (void)upload;

@end
