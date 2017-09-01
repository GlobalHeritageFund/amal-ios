//
//  FirebaseReportDataSource.m
//  Amal
//
//  Created by Soroush Khanlou on 8/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "FirebaseReportDataSource.h"
#import "Report.h"
#import "Firebase.h"
#import "NSArray+Additions.h"
#import "CurrentUser.h"

@interface FirebaseReportDataSource ()

@property (nonatomic) NSArray *reports;

@end

@implementation FirebaseReportDataSource

- (void)beginObserving {
    __weak __typeof(&*self)weakSelf = self;

    [self observeDataSource:^(NSArray<Report *> *reports) {
        weakSelf.reports = reports;
        [self.delegate dataSourceUpdated:self];
    }];
}

- (void)observeDataSource:(void ((^)(NSArray<Report *> *)))block {
    FIRDatabaseReference *reportsDirectory = [[[FIRDatabase database] reference] child:@"reports"];

    FIRDatabaseQuery *query = [[reportsDirectory queryOrderedByChild:@"authorDeviceToken"] queryEqualToValue:[CurrentUser shared].deviceToken];
    
    [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
            return;
        }
        NSArray *reports = [[[[snapshot.value allValues] arrayByTransformingObjectsUsingBlock:^id(id object) {
            return [[Report alloc] initWithDictionary:object];
        }] arrayBySelectingObjectsPassingTest:^BOOL(Report *report) {
            return report.uploadComplete;
        }] sortedArrayUsingComparator:^NSComparisonResult(Report * _Nonnull obj1, Report * _Nonnull obj2) {
            return [obj2.creationDate compare:obj1.creationDate];
        }];
        if (block != nil) {
            block(reports);
        }
    }];

}
@end
