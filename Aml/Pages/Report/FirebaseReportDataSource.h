//
//  FirebaseReportDataSource.h
//  Amal
//
//  Created by Soroush Khanlou on 8/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FirebaseReport;

@protocol DataSourceDelegate <NSObject>

- (void)dataSourceUpdated:(id)dataSource;

@end

@interface FirebaseReportDataSource : NSObject

@property (nonatomic, weak) id<DataSourceDelegate> delegate;

@property (nonatomic, readonly) NSArray<FirebaseReport *> *reports;

@property (readonly) BOOL hasItems;

- (void)beginObserving;

- (void)deleteReport:(FirebaseReport *)report;

@end
