//
//  LocalDraftDataSource.h
//  Amal
//
//  Created by Soroush Khanlou on 8/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FirebaseReportDataSource.h"

@class ReportDraft;

@interface LocalDraftDataSource: NSObject

@property (nonatomic, readonly) NSArray<ReportDraft *> *reports;

@property (nonatomic, weak) id<DataSourceDelegate> delegate;

- (void)addReportDraft:(ReportDraft *)draft;
- (void)removeReportDraft:(ReportDraft *)draft;

@end

@interface LocalDraftStorage : NSObject

- (NSArray<ReportDraft *> *)read;

- (void)write:(NSArray <ReportDraft *> *)reports;

@end
