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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
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
    NSString *cellIdentifiers[] =
    {
        @"ImageCell",
        @"CategoryCell",
        @"ConditionCell",
        @"DamageCell",
        @"NotesCell",
        @"InterventionCell",
        @"MapCell",
        NULL
    };
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifiers[indexPath.row]];
    
    if(indexPath.row == 6) {
        
        MKMapView *view = (id)[cell viewWithTag:1];
        
        view.showsUserLocation = YES;
        view.userTrackingMode = MKUserTrackingModeFollow;
    }
    
    return cell;
}

@end
