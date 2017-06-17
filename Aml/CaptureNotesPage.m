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
#import "ImageDetailViewController.h"

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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteTapped:)];
}

- (void)deleteTapped:(id)sender {
    NSLog(@"delete tapped");
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *estimatedHeights =
    @{
      @"ImageCell": @248,
      @"TitleCell": @55,
      @"TitleNoSeperatorCell": @55,
      @"CategoryCell": @49,
      @"OverallCell": @49,
      @"ConditionCell": @71,
      @"SubtitleCell": @44,
      @"HazardsCell": @43,
      @"SafetyHazardsCell": @43,
      @"InterventionCell": @43,
      @"DescriptionCell": @45,
      @"SyncCell": @43,
      @"MapCell": @250,
      };
    
    return [estimatedHeights[self.cellIdentifiers[indexPath.row]] floatValue];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSArray*)cellIdentifiers
{
    if(self.localPhoto)
        return
        @[
          @"ImageCell",
          @"TitleCell",
          @"CategoryCell",
          @"DescriptionCell",
          @"TitleCell",
          @"ConditionCell",
          @"SubtitleCell",
          @"TitleCell",
          @"HazardsCell",
          @"SafetyHazardsCell",
          @"InterventionCell",
          @"SyncCell",
          @"TitleNoSeperatorCell",
          @"DescriptionCell",
          ];
    
    return
    @[
      @"TitleCell",
      @"CategoryCell",
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
    if(self.localPhoto)
        return
        @[
          [NSNull null],
          [NSNull null],
          @"category",
          @"name",
          [NSNull null],
          @"levelOfDamage",
          [NSNull null],
          [NSNull null],
          @"hazards",
          @"safetyHazards",
          @"intervention",
          @"sync",
          [NSNull null],
          @"notes",
          ];
    
    return
    @[
      [NSNull null],
      @"category",
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
    if(self.localPhoto)
        return 0;
    
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

- (id)settingsValueForKey:(NSString *)key
{
    if(self.localPhoto)
        return self.localPhoto.settings[key];
    
    return [PhotoSettings.shared valueForKey:key];
}

- (void)setSettingsValue:(id)value forKey:(NSString *)key
{
    if(self.localPhoto) {
        
        [self.localPhoto setSettingsValue:value forKey:key];
    }
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
    
    int index = round([[self settingsValueForKey:@"levelOfDamage"] floatValue]) - 1;
    
    return texts[index % texts.count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifiers[indexPath.row]];
    
    int i = 0;
    
    if(self.localPhoto) {
        
        if(indexPath.row == i) {
            
            if(self.localPhoto.image)
                [(UIImageView*)[cell viewWithTag:1] setImage:self.localPhoto.image];
            else
                [self.localPhoto load:^(LocalPhoto *localPhoto) {
                    
                    [(UIImageView*)[cell viewWithTag:1] setImage:localPhoto.image];
                }];
        }
        
        i++;
    }
    
    if(indexPath.row == i)
        [(id)[cell viewWithTag:1] setText:@"CATEGORY"];
    
    i += 2;
    
    if(indexPath.row == i)
        [(id)[cell viewWithTag:1] setText:@"LEVEL OF DAMAGE"];
    
    i += 2;
    
    if(indexPath.row == i)
        [(id)[cell viewWithTag:1] setText:@"NAME"];
    
    if(indexPath.row == i)
        [(id)[cell viewWithTag:1] setText:self.levelOfDamageText];
    
    i += 1;
    
    if(indexPath.row == i)
        [(id)[cell viewWithTag:1] setText:@"ASSESS"];
    
    i += 4;
    
    if(indexPath.row == i)
        [(id)[cell viewWithTag:1] setText:@"NOTES"];
    
    if([cell isKindOfClass:[GenericSettingsCell class]]) {
        
        GenericSettingsCell *settingCell = (id)cell;
        
        id settingsKey = self.settingsKeys[indexPath.row];
        
        if([settingsKey isKindOfClass:[NSString class]]) {
            
            settingCell.settingsKey = settingsKey;
            settingCell.value = [self settingsValueForKey:settingsKey];
            
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
    [self setSettingsValue:value forKey:cell.settingsKey];
    
    if([cell.settingsKey isEqual:@"levelOfDamage"]) {
        
        NSArray *paths = @[[NSIndexPath indexPathForRow:6 inSection:0]];
        
        [self.tableView reloadRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if([cell.settingsKey isEqual:@"sync"]) {
        
        if([[self settingsValueForKey:@"sync"] boolValue])
            [self.localPhoto uploadEverything];
        else
            [self.localPhoto unsync];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showImageDetail"]) {
        ImageDetailViewController *imageDetail = segue.destinationViewController;
        [imageDetail loadView];
        imageDetail.imageView.image = self.localPhoto.image;
    }
}

@end
