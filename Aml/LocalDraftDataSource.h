//
//  LocalDraftDataSource.h
//  Amal
//
//  Created by Soroush Khanlou on 8/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReportDraft;

@interface LocalDraftDataSource : NSObject

- (NSArray<ReportDraft *> *)read;
- (void)write:(NSArray <ReportDraft *> *)reports;
- (void)addReportDraft:(ReportDraft *)draft;

@end
