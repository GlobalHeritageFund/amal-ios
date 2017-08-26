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

@interface CreateReportViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) ReportHeaderView *reportHeader;

@end

@implementation CreateReportViewController

@dynamic view;

- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft {
    self = [super init];
    if (!self) return nil;

    _reportDraft = reportDraft;

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

    self.uploadButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(upload:)];
    self.navigationItem.rightBarButtonItem = self.uploadButton;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];

    [self configureView];
}

static NSDateIntervalFormatter *formatter = nil;

- (void)configureView {
    if (formatter == nil) {
        formatter = [[NSDateIntervalFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
    }
    self.reportHeader.dateLabel.text = [formatter stringFromDate:self.reportDraft.minDate toDate:self.reportDraft.maxDate];
    self.reportHeader.countLabel.text = @"75 photos";
    self.reportHeader.uploadStateLabel.text = @"Published 75 of 75";
    self.reportHeader.totalProgressView.progress = 0.2;
    self.reportHeader.creationDateLabel.text = @"Created 27 June 2017";
    self.reportHeader.reportStateLabel.text = @"Published";

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
        return 1;
    }
    return self.reportDraft.photos.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.reportDraft.photos removeObjectAtIndex:indexPath.row];
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
    LocalPhoto *photo = self.reportDraft.photos[indexPath.row];
    cell.imageView.image = photo.image;
    cell.textLabel.text = (photo.metadata.name.length) ? photo.metadata.name : @"Unnamed";
    cell.detailTextLabel.text = (photo.metadata.notes.length) ? photo.metadata.notes : @"No notes.";
    cell.progressView.observedProgress = self.upload.progresses[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LocalPhoto *photo = self.reportDraft.photos[indexPath.row];
        [self.delegate createReportViewController:self didSelectPhoto:photo];
    }
    if (indexPath.section == 1) {
        [self.delegate createReportViewControllerDidTapAddPhoto:self];
    }
}

- (void)updateUploadButtonState {
    BOOL reportHasAtLeastOneItem = self.reportDraft.photos.count != 0;
    self.navigationItem.rightBarButtonItem.enabled = reportHasAtLeastOneItem;
}

- (void)upload:(id)sender {
    self.reportDraft.title = self.reportHeader.titleField.text ?: @"";
    [self.delegate createReportViewController:self didTapUploadWithDraft:self.reportDraft];
}

- (void)cancel:(id)sender {
    [self.delegate createReportViewControllerDidTapCancel:self];
}

@end
