//
//  SyncPage.m
//  Amal
//
//  Created by Dustin Dettmer on 4/18/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "SyncPage.h"

@interface SyncPage ()

@end

@implementation SyncPage

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:@"Cell"];
}

@end
