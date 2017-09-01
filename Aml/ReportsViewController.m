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
#import "LocalDraftDataSource.h"
#import "ReportDraft.h"

@interface ReportsViewController () <DataSourceDelegate>

@property (nonatomic) FirebaseReportDataSource *publishedReports;
@property (nonatomic) LocalDraftDataSource *localDrafts;

@end

@implementation ReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Reports";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(composeTapped:)];

    self.publishedReports = [[FirebaseReportDataSource alloc] init];
    [self.publishedReports beginObserving];
    self.publishedReports.delegate = self;

    self.localDrafts = [[LocalDraftDataSource alloc] init];
}

- (void)dataSourceUpdated:(id)dataSource {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.localDrafts.reports.count;
    } else if (section == 1) {
        return self.publishedReports.reports.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[ReportCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];

    ReportViewModel *viewModel;
    if (indexPath.section == 0) {
        ReportDraft *draft = self.localDrafts.reports[indexPath.row];
        viewModel = [[ReportViewModel alloc] initWithReport:draft];
    } else if (indexPath.section == 1) {
        Report *report = self.publishedReports.reports[indexPath.row];
        viewModel = [[ReportViewModel alloc] initWithReport:report];
    }
    
    cell.textLabel.text = viewModel.title;
    cell.detailTextLabel.text = viewModel.imageCountString;

    [[[viewModel.photos.firstObject loadThumbnailImage] then:^id _Nullable(id  _Nonnull image) {
        if ([tableView cellForRowAtIndexPath:indexPath] == cell) {
            cell.imageView.image = image;
        }
        return nil;
    }] catch:^(NSError * _Nonnull error) {
        NSLog(@"error %@", error);
    }];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Drafts";
    }
    if (section == 1) {
        return @"Published";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ReportDraft *reportDraft = self.localDrafts.reports[indexPath.row];
        [self.delegate reportsViewController:self didTapDraft:reportDraft];
    } else if (indexPath.section == 1) {
        Report *report = self.publishedReports.reports[indexPath.row];
        [self.delegate reportsViewController:self didTapReport:report];
    }
}

- (void)composeTapped:(id)sender {
    [FIRAnalytics logEventWithName:@"report_compose_tapped" parameters:nil];
    [self.delegate reportsViewControllerDidTapCompose:self];
}

@end
