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

@interface CreateReportViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UIBarButtonItem *uploadButton;
@property (nonatomic) ReportUpload *upload;

@end

@implementation CreateReportViewController

@dynamic view;

- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft {
    self = [super init];
    if (!self) return nil;

    _reportDraft = reportDraft;
    _upload = [[ReportUpload alloc] initWithReportDraft:reportDraft];

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

- (UITextField *)textField {
    if (!_textField) {
        UITextField *textField = [[UITextField alloc] init];
        textField.placeholder = @"Title";
        self.textField = textField;
    }
    return _textField;
}

- (void)loadView {
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Create Report";

    self.uploadButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(upload:)];
    self.navigationItem.rightBarButtonItem = self.uploadButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.reportDraft.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TextFieldTableViewCell *cell = [[TextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        cell.hostedTextfield = self.textField;
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

- (void)upload:(id)sender {
    self.title = @"Uploading...";
    self.uploadButton.enabled = NO;
    self.reportDraft.title = self.textField.text ?: @"";
    [self.upload upload];
    [self.upload.promise then:^id _Nullable(id  _Nonnull object) {
        self.title = @"Uploaded!";
        return nil;
    }];
}

@end
