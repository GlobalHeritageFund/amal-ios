//
//  CaptureNotesPage.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "CaptureNotesPage.h"
#import "UIViewController+Additions.h"
#import <MapKit/MapKit.h>

@interface CaptureNotesPage ()

@end

@implementation CaptureNotesPage {
    CLLocationManager *locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    locationManager = [CLLocationManager new];
    
    [locationManager requestWhenInUseAuthorization];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSArray*)cellIdentifiers
{
    return
    @[
      @"TitleCell",
      @"CategoryCell",
      @"TitleCell",
      @"OverallCell",
      @"TitleCell",
      @"ConditionCell",
      @"SubtitleCell",
      @"TitleCell",
      @"HazardsCell",
      @"SafetyHazardsCell",
      @"InterventionCell",
      @"TitleNoSeperatorCell",
      @"DescriptionCell",
      ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellIdentifiers.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Test";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 85;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [tableView dequeueReusableCellWithIdentifier:@"Header"];
    
    UIButton *backBtn = (id)[header viewWithTag:1];
    
    [backBtn addTarget:self action:@selector(popNavigationController) forControlEvents:UIControlEventTouchUpInside];
    
    return header;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifiers[indexPath.row]];
    
    if(indexPath.row == 0)
        [(id)[cell viewWithTag:1] setText:@"CATEGORY"];
    
    if(indexPath.row == 2)
        [(id)[cell viewWithTag:1] setText:@"OVERALL CONDITION"];
    
    if(indexPath.row == 4)
        [(id)[cell viewWithTag:1] setText:@"LEVEL OF DAMAGE"];
    
    if(indexPath.row == 6)
        [(id)[cell viewWithTag:1] setText:@"Level 3 - Moderate damage, poor condition"];
    
    if(indexPath.row == 7)
        [(id)[cell viewWithTag:1] setText:@"ASSESS"];
    
    if(indexPath.row == 11)
        [(id)[cell viewWithTag:1] setText:@"NOTES"];
    
    return cell;
}

@end
