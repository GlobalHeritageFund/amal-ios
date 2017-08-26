//
//  CreateReportViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "CreateReportViewController.h"
#import "UIColor+Additions.h"
#import "ReportDraft.h"
#import "LocalPhoto.h"
#import "AMLMetadata.h"
#import "ReportUpload.h"
#import "TextFieldTableViewCell.h"
#import "ReportPhotoTableViewCell.h"
#import "ReportHeaderView.h"
#import "UIColor+Additions.h"
#import "NSObject+Helpers.h"

@interface CreateReportViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) ReportHeaderView *reportHeader;

@end

@implementation CreateReportViewController

@dynamic view;

- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft {
    self = [super init];
    if (!self) return nil;

    _viewModel = [[ReportViewModel alloc] initWithReport:reportDraft];

    return self;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        self.tableView = tableView;
    }
    return _tableView;
}

- (void)loadView {
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Create Report";

    self.reportHeader = [[ReportHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    self.tableView.tableHeaderView = self.reportHeader;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];

    [self configureView];
}

- (void)setViewModel:(ReportViewModel *)viewModel {
    _viewModel = viewModel;

    [self configureView];
    [self.tableView reloadData];
}

- (void)configureView {
    self.reportHeader.titleField.enabled = self.viewModel.isEditable;
    self.reportHeader.dateLabel.text = self.viewModel.dateInterval;
    self.reportHeader.countLabel.text = self.viewModel.imageCountString;
    [self.reportHeader.uploadStateButton setTitle:self.viewModel.uploadState forState:UIControlStateNormal];
    self.reportHeader.uploadStateButton.enabled = self.viewModel.isEditable;
    [self.reportHeader.uploadStateButton addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
    self.reportHeader.totalProgressView.observedProgress = self.viewModel.progress;
    self.reportHeader.creationDateLabel.text = self.viewModel.creationDateString;
    self.reportHeader.reportStateLabel.text = self.viewModel.reportState;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        if (self.viewModel.isEditable) {
            return 1;
        } else {
            return 0;
        }
    }
    return self.viewModel.report.photoCount;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.viewModel.isEditable) {
        return NO;
    }
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel.draft.photos removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self updateUploadButtonState];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.textLabel.text = @"Add...";
        cell.textLabel.textColor = [UIColor amalTeal];
        return cell;
    }
    ReportPhotoTableViewCell *cell = [[ReportPhotoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    LocalPhoto *photo = self.viewModel.draft.photos[indexPath.row];
    cell.imageView.image = photo.image;
    cell.textLabel.text = (photo.metadata.name.length) ? photo.metadata.name : @"Unnamed";
    cell.detailTextLabel.text = (photo.metadata.notes.length) ? photo.metadata.notes : @"No notes.";
    cell.progressView.observedProgress = self.viewModel.upload.progresses[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LocalPhoto *photo = self.viewModel.draft.photos[indexPath.row];
        [self.delegate createReportViewController:self didSelectPhoto:photo];
    }
    if (indexPath.section == 1) {
        [self.delegate createReportViewControllerDidTapAddPhoto:self];
    }
}

- (void)updateUploadButtonState {
    BOOL reportHasAtLeastOneItem = self.viewModel.imageCountString != 0;
    self.navigationItem.rightBarButtonItem.enabled = reportHasAtLeastOneItem;
}

- (void)upload:(id)sender {
    self.viewModel.draft.title = self.reportHeader.titleField.text ?: @"";
    [self.delegate createReportViewController:self didTapUploadWithDraft:self.viewModel.draft];
}

- (void)cancel:(id)sender {
    [self.delegate createReportViewControllerDidTapCancel:self];
}

@end
