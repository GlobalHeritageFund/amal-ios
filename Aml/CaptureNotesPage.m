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
#import "PhotoSettings.h"

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

- (NSArray*)settingsKeys
{
    return
    @[
      [NSNull null],
      @"category",
      [NSNull null],
      @"condition",
      [NSNull null],
      @"levelOfDamage",
      [NSNull null],
      [NSNull null],
      @"hazards",
      @"safetyHazards",
      @"intervention",
      [NSNull null],
      @"notes",
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
    return 44;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [tableView dequeueReusableCellWithIdentifier:@"Header"];
    
    UIButton *backBtn = (id)[header viewWithTag:1];
    
    [backBtn addTarget:self action:@selector(clearSettings:) forControlEvents:UIControlEventTouchUpInside];
    
    return header;
}

- (void)clearSettings:(id)sender
{
    [PhotoSettings.shared clearSettings];
    
    [self.tableView reloadData];
}

- (id)valueForKey:(NSString *)key
{
    if(self.localPhoto)
        return self.localPhoto.settings[key];
    
    return [PhotoSettings.shared valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if(self.localPhoto)
        [self.localPhoto setSettingsValue:value forKey:key];
    else
        [PhotoSettings.shared setValue:value forKey:key];
}

- (NSString*)levelOfDamageText
{
    NSArray *texts =
    @[
      @"Level 1 - No damage, good condition",
      @"Level 2 - Minor damage, fair condition",
      @"Level 3 - Moderate damage, poor condition",
      @"Level 4 - Severe damage, very bad condition",
      @"Level 5 - Collapsed, destroyed",
      ];
    
    int index = round([[self valueForKey:@"levelOfDamage"] floatValue]);
    
    return texts[index % texts.count];
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
        [(id)[cell viewWithTag:1] setText:self.levelOfDamageText];
    
    if(indexPath.row == 7)
        [(id)[cell viewWithTag:1] setText:@"ASSESS"];
    
    if(indexPath.row == 11)
        [(id)[cell viewWithTag:1] setText:@"NOTES"];
    
    if([cell isKindOfClass:[GenericSettingsCell class]]) {
        
        GenericSettingsCell *settingCell = (id)cell;
        
        id settingsKey = self.settingsKeys[indexPath.row];
        
        if([settingsKey isKindOfClass:[NSString class]]) {
            
            settingCell.settingsKey = settingsKey;
            settingCell.value = [self valueForKey:settingsKey];
            
            settingCell.delegate = self;
        }
        else {
            
            settingCell.delegate = nil;
            
            [settingCell setValue:[NSNull null]];
        }
    }
    
    return cell;
}

- (void)reportValueChange:(id)value forCell:(GenericSettingsCell *)cell
{
    [self setValue:value forKey:cell.settingsKey];
    
    if([cell.settingsKey isEqual:@"levelOfDamage"]) {
        
        NSArray *paths = @[[NSIndexPath indexPathForRow:6 inSection:0]];
        
        [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
