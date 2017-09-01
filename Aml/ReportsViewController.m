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
#import "ReportCell.h"

@interface ReportsViewController () <DataSourceDelegate>

@property (nonatomic) FirebaseReportDataSource *publishedReports;

@end

@implementation ReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Reports";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(composeTapped:)];

    self.publishedReports = [[FirebaseReportDataSource alloc] init];
    [self.publishedReports beginObserving];
    self.publishedReports.delegate = self;
}

- (void)dataSourceUpdated:(id)dataSource {
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.publishedReports.reports.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[ReportCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

    Report *report = self.publishedReports.reports[indexPath.row];
    cell.textLabel.text = report.title;
    cell.detailTextLabel.text = [[ReportViewModel alloc] initWithReport:report].imageCountString;

    [[[report.photos.firstObject loadThumbnailImage] then:^id _Nullable(id  _Nonnull image) {
        if ([tableView cellForRowAtIndexPath:indexPath] == cell) {
            cell.imageView.image = image;
        }
        return nil;
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"error %@", error);
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Report *report = self.publishedReports.reports[indexPath.row];
    [self.delegate reportsViewController:self didTapReport:report];
}

- (void)composeTapped:(id)sender {
    [FIRAnalytics logEventWithName:@"report_compose_tapped" parameters:nil];
    [self.delegate reportsViewControllerDidTapCompose:self];
}

@end
