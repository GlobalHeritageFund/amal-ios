//
//  ReportUpload.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"
#import "ReportViewModel.h"

@class ReportDraft, Resource;

@interface ReportUpload : NSObject<ReportProtocol>

@property (nonatomic, readonly) ReportDraft *reportDraft;

@property (nonatomic, readonly) Promise<FirebaseReport *> *promise;

@property (nonatomic, readonly) NSArray<NSProgress *> *progresses;

- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft;

- (void)upload;

- (NSDictionary *)dictionaryRepresentationWithResources:(NSArray <NSDictionary *> *)resources;

@end
