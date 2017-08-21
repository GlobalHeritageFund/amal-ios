//
//  FirebaseReportDataSource.h
//  Amal
//
//  Created by Soroush Khanlou on 8/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Report;

@interface FirebaseReportDataSource : NSObject

- (void)observeDataSource:(void ((^)(NSArray<Report *> *)))block;

@end
