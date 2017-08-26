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
#import "FirebaseReportDataSource.h"

@interface ReportsViewController ()

@property (nonatomic) NSArray<Report *> *reports;

@end

@implementation ReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Reports";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeTapped:)];

    __weak __typeof(&*self)weakSelf = self;
    [[[FirebaseReportDataSource alloc] init] observeDataSource:^(NSArray<Report *> *reports) {
        weakSelf.reports = reports;
        [weakSelf.tableView reloadData];
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

    [[[report.images.firstObject loadThumbnailImage] then:^id _Nullable(id  _Nonnull image) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Report *report = self.reports[indexPath.row];
    [self.delegate reportsViewController:self didTapReport:report];
}

- (void)composeTapped:(id)sender {
    [self.delegate reportsViewControllerDidTapCompose:self];
}

@end
