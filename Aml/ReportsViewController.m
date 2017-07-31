//
//  ReportsViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportsViewController.h"
#import "Firebase.h"
#import "CurrentUser.h"

@interface ReportsViewController ()

@end

@implementation ReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Reports";

    FIRDatabaseReference *reportsDirectory = [[[FIRDatabase database] reference] child:@"reports"];

    FIRDatabaseQuery *query = [[reportsDirectory queryOrderedByChild:@"authorDeviceToken"] queryEqualToValue:[CurrentUser shared].deviceToken];
    [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"val: %@", snapshot.value);
    }];
}

@end
