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
#import "FirebaseReport.h"
#import "NSArray+Additions.h"
#import "FirebaseReportDataSource.h"
#import "ReportCell.h"
#import "LocalDraftDataSource.h"
#import "ReportDraft.h"
#import "EmptyState.h"
#import "UIColor+Additions.h"
#import "CGGeometry.h"

@interface ReportsViewController () <DataSourceDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) FirebaseReportDataSource *publishedReports;
@property (nonatomic) LocalDraftDataSource *localDrafts;
@property (nonatomic) EmptyStateView *emptyState;

@end

@implementation ReportsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;

    [self beginLoading];

    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Reports", @"A heading for the Reports list screen.");

    self.view.backgroundColor = [UIColor backgroundColor];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"New", @"A button to create a new report.") style:UIBarButtonItemStylePlain target:self action:@selector(composeTapped:)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)beginLoading {
    self.publishedReports = [[FirebaseReportDataSource alloc] init];
    [self.publishedReports beginObserving];
    self.publishedReports.delegate = self;

    self.localDrafts = [[LocalDraftDataSource alloc] init];
    self.localDrafts.delegate = self;

    [self reloadData];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;

    self.emptyState.frame = CGRectInsetToSize(self.view.bounds, CGSizeMake(300, 400));
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        tableView.dataSource = self;
        tableView.delegate = self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
    }
    return _tableView;
}

- (EmptyStateView *)emptyState {
    if (!_emptyState) {
        EmptyStateView *emptyState = [[EmptyStateView alloc] init];
        emptyState.imageView.image = [UIImage imageNamed:@"reports_bg"];
        emptyState.label.text = NSLocalizedString(@"To create a report, first take some photos, then tap \"New\" at the top.", @"A label that explains the reports screen to users who have created any reports or drafts yet.");
        [self.view addSubview:emptyState];
        self.emptyState = emptyState;
    }
    return _emptyState;
}

- (void)dataSourceUpdated:(id)dataSource {
    [self reloadData];
}

- (void)reloadData {
    [self.tableView reloadData];

    BOOL hasItems = self.publishedReports.hasItems || self.localDrafts.hasDrafts;

    self.tableView.hidden = !hasItems;
    self.emptyState.hidden = hasItems;
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
        FirebaseReport *report = self.publishedReports.reports[indexPath.row];
        viewModel = [[ReportViewModel alloc] initWithReport:report];
    }

    if (viewModel.isEditable) {
        NSString *title = viewModel.title;
        if (title.length == 0) {
            title = NSLocalizedString(@"Untitled", @"A label for a report with no name.");
        }
        cell.textLabel.text = title;
    } else {
        cell.textLabel.text = viewModel.title;
    }
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
    if (section == 0 && self.localDrafts.hasDrafts) {
        return NSLocalizedString(@"Drafts", @"A header for a section that shows the user's draft reports.");
    }
    if (section == 1 && self.publishedReports.hasItems) {
        return NSLocalizedString(@"Published", @"A header for the section that shows the user's published reports.");
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ReportDraft *reportDraft = self.localDrafts.reports[indexPath.row];
        [self.delegate reportsViewController:self didTapDraft:reportDraft];
    } else if (indexPath.section == 1) {
        FirebaseReport *report = self.publishedReports.reports[indexPath.row];
        [self.delegate reportsViewController:self didTapReport:report];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 || indexPath.section == 1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    if (indexPath.section == 0) {
        ReportDraft *reportDraft = self.localDrafts.reports[indexPath.row];

        [self.delegate reportsViewController:self shouldDeleteDraft:reportDraft atIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        FirebaseReport *report = self.publishedReports.reports[indexPath.row];
        [self.delegate reportsViewController:self shouldDeleteReport:report atIndexPath:indexPath];
    }
}

- (void)composeTapped:(id)sender {
    [FIRAnalytics logEventWithName:@"report_compose_tapped" parameters:nil];
    [self.delegate reportsViewControllerDidTapCompose:self];
}

@end
