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
#import "FirebaseReport.h"
#import "MapViewController.h"
#import "NSArray+Additions.h"
#import "CurrentUser.h"
#import "DatabasePicker.h"

@interface ReportDetailViewController ()<UITableViewDelegate, UITableViewDataSource, ReportHeaderViewDelegate>

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
    return [self initWithReportViewModel:[[ReportViewModel alloc] initWithReport:reportDraft]];
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

    self.reportHeader = [[ReportHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 320)];
    self.tableView.tableHeaderView = self.reportHeader;
    self.reportHeader.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];

    [self.reportHeader.mapView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapViewTapped:)]];
    [self configureView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppeared:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDisappeared:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self copyValuesFromFieldsToViewModel];
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
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.viewModel.coordinateMidpoint, 1500, 1500);
    [self.reportHeader.mapView setRegion:viewRegion animated:NO];
    self.reportHeader.enabled = self.viewModel.isEditable;
    self.reportHeader.titleField.text = self.viewModel.title;
    self.reportHeader.assessorEmailField.text = self.viewModel.email;
    self.reportHeader.dateLabel.text = self.viewModel.dateInterval;
    self.reportHeader.countLabel.text = self.viewModel.imageCountString;
    [self.reportHeader.uploadStateButton setTitle:self.viewModel.uploadState forState:UIControlStateNormal];
    self.reportHeader.uploadStateButton.enabled = self.viewModel.isEditable;
    [self.reportHeader.uploadStateButton addTarget:self action:@selector(upload:) forControlEvents:UIControlEventTouchUpInside];
    self.reportHeader.totalProgressView.observedProgress = self.viewModel.progress;
    self.reportHeader.creationDateLabel.text = self.viewModel.creationDateString;
    self.reportHeader.reportStateLabel.text = self.viewModel.reportState;
    self.reportHeader.reportStateLabel.textColor = self.viewModel.reportStateColor;
    self.reportHeader.totalProgressView.hidden = !self.viewModel.showProgressBars;

    if ([CurrentUser shared].isEAMENAUnlocked || [CurrentUser shared].isLebanonUnlocked) {
        self.reportHeader.databasePicker.nameLabel.text = @"Database target";
        self.reportHeader.databasePicker.valueLabel.text = [DatabaseTargetMakeString(self.viewModel.databaseTarget) capitalizedString];
    }

    self.reportHeader.assessorEmailField.enabled = !self.viewModel.hasPrefilledEmail;
    
    [self.reportHeader.databasePicker setNeedsLayout];

    if (self.viewModel.finalized) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTapped:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)mapViewTapped:(UITapGestureRecognizer *)sender {
    if (self.viewModel.photos.count == 0) {
        return;
    }
    MapViewController *mapViewController = [[MapViewController alloc] initWithPhotos:self.viewModel.photos];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (void)shareButtonTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Share" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Web Report" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = [NSString stringWithFormat:@"https://app.amal.global/reports/%@", ((FirebaseReport *)self.viewModel.finalized).firebaseID];
        NSArray *objectsToShare = @[[NSURL URLWithString:url]];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"PDF Report" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [((FirebaseReport *)self.viewModel.finalized).pdfURL then:^id _Nullable(id  _Nonnull url) {
            NSArray *objectsToShare = @[url];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            [self presentViewController:activityViewController animated:YES completion:nil];
            return nil;
        }];

    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
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
    cell.progressView.hidden = !self.viewModel.showProgressBars;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        LocalPhoto *localPhoto = self.viewModel.draft.localPhotos[indexPath.row];
        RemotePhoto *remotePhoto = ((FirebaseReport *)self.viewModel.finalized).photos[indexPath.row];
        if (localPhoto) {
            [self.delegate reportDetailViewController:self didSelectLocalPhoto:localPhoto];
        } else if (remotePhoto) {
            [self.delegate reportDetailViewController:self didSelectRemotePhoto:remotePhoto];
        }
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
    [self copyValuesFromFieldsToViewModel];
    [self.delegate reportDetailViewController:self didTapUploadWithDraft:self.viewModel.draft];
}

- (void)cancel:(id)sender {
    [self copyValuesFromFieldsToViewModel];
    [self.delegate reportDetailViewControllerDidTapCancel:self];
}

- (void)copyValuesFromFieldsToViewModel {
    self.viewModel.draft.title = self.reportHeader.titleField.text ?: @"";
    self.viewModel.draft.email = self.reportHeader.assessorEmailField.text ?: @"";
}

- (void)reportHeaderViewTappedDatabasePicker:(ReportHeaderView *)headerView {
    [self.delegate reportDetailViewControllerDidTapDatabasePicker:self];
}

@end
