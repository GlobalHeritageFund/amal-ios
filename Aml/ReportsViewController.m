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
#import "Report.h"
#import "NSArray+Additions.h"

@interface ReportsViewController ()

@property (nonatomic) NSArray<Report *> *reports;

@end

@implementation ReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Reports";

    FIRDatabaseReference *reportsDirectory = [[[FIRDatabase database] reference] child:@"reports"];

    FIRDatabaseQuery *query = [[reportsDirectory queryOrderedByChild:@"authorDeviceToken"] queryEqualToValue:[CurrentUser shared].deviceToken];
    __weak __typeof(&*self)weakSelf = self;
    [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        weakSelf.reports = [[snapshot.value allValues] arrayByTransformingObjectsUsingBlock:^id(id object) {
            return [[Report alloc] initWithDictionary:object];
        }];
        [self.tableView reloadData];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reports.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

    Report *report = self.reports[indexPath.row];
    cell.textLabel.text = report.title;
    cell.detailTextLabel.text = report.imageCountString;

    [[[report.images.firstObject fetchFirebaseImage] then:^id _Nullable(id  _Nonnull image) {
        if ([tableView cellForRowAtIndexPath:indexPath] == cell) {
            cell.imageView.image = image;
            [cell setNeedsLayout];
        }
        return nil;
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"error %@", error);
    }];
    return cell;
}

@end
