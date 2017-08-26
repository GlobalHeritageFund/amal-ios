//
//  ReportDetailViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportDetailViewController.h"
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

@interface ReportDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) ReportHeaderView *reportHeader;
@property (nonatomic) UIEdgeInsets oldInsets;

@end

@implementation ReportDetailViewController

@dynamic view;

- (instancetype)initWithReportViewModel:(ReportViewModel *)viewModel {
    self = [super init];
    if (!self) return nil;

    _viewModel = viewModel;

    return self;
}

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
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        self.tableView = tableView;
    }
    return _tableView;
}

- (void)loadView {
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Report";

    self.reportHeader = [[ReportHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    self.tableView.tableHeaderView = self.reportHeader;
    self.reportHeader.titleField.text = self.viewModel.title;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];

    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppeared:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDisappeared:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardAppeared:(NSNotification *)note {
    CGRect keyboardRect = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    self.oldInsets = self.tableView.contentInset;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.oldInsets.top, 0.0f, CGRectGetHeight(keyboardRect), 0.0f);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardDisappeared:(NSNotification *)note {
    self.tableView.contentInset = self.oldInsets;
    self.tableView.scrollIndicatorInsets = self.oldInsets;
}

- (void)setViewModel:(ReportViewModel *)viewModel {
    _viewModel = viewModel;

    [self configureView];
    [self.tableView reloadData];
}

- (void)configureView {
    self.reportHeader.titleField.enabled = self.viewModel.isEditable;
    self.reportHeader.dateLabel.text = self.viewModel.dateInterval;
    self.reportHeader.dateLabel.text = self.viewModel.dateInterval;
    self.reportHeader.countLabel.text = self.viewModel.imageCountString;
    [self.reportHeader.uploadStateButton setTitle:self.viewModel.uploadState forState:UIControlStateNormal];
    self.reportHeader.uploadStateButton.enabled = self.viewModel.isEditable;
    [self.reportHeader.uploadStateButton addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
    self.reportHeader.totalProgressView.observedProgress = self.viewModel.progress;
    self.reportHeader.creationDateLabel.text = self.viewModel.creationDateString;
    self.reportHeader.reportStateLabel.text = self.viewModel.reportState;
    self.reportHeader.reportStateLabel.textColor = self.viewModel.reportStateColor;
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
    [self.viewModel.draft.localPhotos removeObjectAtIndex:indexPath.row];
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
    id<PhotoProtocol> photo = self.viewModel.photos[indexPath.row];
    [[photo loadThumbnailImage] then:^id _Nullable(id  _Nonnull object) {
        if ([tableView cellForRowAtIndexPath:indexPath] != nil) {
            cell.imageView.image = object;
        }
        return nil;
    }];

    cell.textLabel.text = (photo.metadata.name.length) ? photo.metadata.name : @"Unnamed";
    cell.detailTextLabel.text = (photo.metadata.notes.length) ? photo.metadata.notes : @"No notes.";
    cell.progressView.observedProgress = self.viewModel.upload.progresses[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LocalPhoto *photo = self.viewModel.draft.localPhotos[indexPath.row];
        [self.delegate reportDetailViewController:self didSelectPhoto:photo];
    }
    if (indexPath.section == 1) {
        [self.delegate reportDetailViewControllerDidTapAddPhoto:self];
    }
}

- (void)updateUploadButtonState {
    BOOL reportHasAtLeastOneItem = self.viewModel.imageCountString != 0;
    self.reportHeader.uploadStateButton.enabled = reportHasAtLeastOneItem;
}

- (void)upload:(id)sender {
    self.viewModel.draft.title = self.reportHeader.titleField.text ?: @"";
    [self.delegate reportDetailViewController:self didTapUploadWithDraft:self.viewModel.draft];
}

- (void)cancel:(id)sender {
    [self.delegate reportDetailViewControllerDidTapCancel:self];
}

@end