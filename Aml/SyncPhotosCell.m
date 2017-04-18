//
//  SyncPhotosCell.m
//  Amal
//
//  Created by Dustin Dettmer on 4/18/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "SyncPhotosCell.h"
#import "Firebase.h"

@interface SyncPhotosCell ()

@property (weak) IBOutlet UISwitch *switchView;

@end

@implementation SyncPhotosCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.switchView.on = NO;
}

- (IBAction)toggleSync:(id)sender
{
    [[[FIRDatabase database] reference] keepSynced:self.switchView.on];
}

@end
