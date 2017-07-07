//
//  CreateReportViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "CreateReportViewController.h"
#import "UIColor+Additions.h"
#import "Report.h"
#import "LocalPhoto.h"
#import "AMLMetadata.h"
#import "ReportUploader.h"

@interface CreateReportViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) UITableView *tableView;

@end

@implementation CreateReportViewController

@dynamic view;

- (instancetype)initWithReport:(Report *)report {
    self = [super init];
    if (!self) return nil;

    _report = report;

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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(upload:)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.report.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    LocalPhoto *photo = self.report.photos[indexPath.row];
    cell.imageView.image = photo.image;
    cell.textLabel.text = (photo.metadata.name.length) ? photo.metadata.name : @"Unnamed";
    cell.detailTextLabel.text = (photo.metadata.notes.length) ? photo.metadata.notes : @"No notes.";
    return cell;
}

- (void)upload:(id)sender {
    [[ReportUploader new] upload:self.report completion:^{
        NSLog(@"DONENNN");
    }];
}

@end
