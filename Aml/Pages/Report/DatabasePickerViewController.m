//
//  DatabasePickerViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 8/16/20.
//  Copyright © 2020 Global Heritage Fund. All rights reserved.
//

#import "DatabasePickerViewController.h"
#import "CurrentUser.h"
#import "DatabaseTarget.h"

@interface DatabasePickerViewController ()

@property (nonatomic) NSArray *availableDatabaseTargets;

@end

@implementation DatabasePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.availableDatabaseTargets = [CurrentUser shared].unlockedDatabaseTargets;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"database_cell"];

    self.title = @"Select a Database";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.availableDatabaseTargets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"database_cell" forIndexPath:indexPath];

    DatabaseTarget database = [self.availableDatabaseTargets[indexPath.row] intValue];
    cell.textLabel.text = [DatabaseTargetMakeString(database) capitalizedString];

    cell.accessoryType = self.selectedDatabase == database ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DatabaseTarget database = [self.availableDatabaseTargets[indexPath.row] intValue];
    self.selectedDatabase = database;
    [self.tableView reloadData];
    [self.delegate databasePicker:self didPickNewDatabase:database];
}

@end
