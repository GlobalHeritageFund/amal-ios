//
//  FirebaseReportDataSource.m
//  Amal
//
//  Created by Soroush Khanlou on 8/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "FirebaseReportDataSource.h"
#import "FirebaseReport.h"
#import "Firebase.h"
#import "NSArray+Additions.h"
#import "CurrentUser.h"

@interface FirebaseReportDataSource ()

@property (nonatomic) NSArray *reports;

@end

@implementation FirebaseReportDataSource

- (void)beginObserving {
    __weak __typeof(&*self)weakSelf = self;

    [self observeDataSource:^(NSArray<FirebaseReport *> *reports) {
        weakSelf.reports = reports;
        [self.delegate dataSourceUpdated:self];
    }];
}

- (void)observeDataSource:(void ((^)(NSArray<FirebaseReport *> *)))block {
    FIRDatabaseReference *reportsDirectory = [[[FIRDatabase database] reference] child:@"reports"];

    FIRDatabaseQuery *query = [[reportsDirectory queryOrderedByChild:@"authorDeviceToken"] queryEqualToValue:[CurrentUser shared].deviceToken];
    
    [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
            block(@[]);
            return;
        }
        NSDictionary *reportDicts = snapshot.value;
        NSArray *reports = [[[[reportDicts allKeys] arrayByTransformingObjectsUsingBlock:^id(id key) {
            return [[FirebaseReport alloc] initWithKey:key dictionary:reportDicts[key]];
        }] arrayBySelectingObjectsPassingTest:^BOOL(FirebaseReport *report) {
            return report.uploadComplete;
        }] sortedArrayUsingComparator:^NSComparisonResult(FirebaseReport * _Nonnull obj1, FirebaseReport * _Nonnull obj2) {
            return [obj2.creationDate compare:obj1.creationDate];
        }];
        if (block != nil) {
            block(reports);
        }
    }];

}

- (void)deleteReport:(FirebaseReport *)report {
    [[[[[FIRDatabase database] reference] child:@"reports"] child:report.firebaseID] removeValue];
}

- (BOOL)hasItems {
    return self.reports.count != 0;
}
@end
