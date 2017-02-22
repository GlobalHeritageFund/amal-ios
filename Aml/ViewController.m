//
//  ViewController.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak) IBOutlet UIButton *cameraButton;

@end

@implementation ViewController

- (IBAction)swapCamera:(UIButton*)sender
{
    sender.selected = !sender.selected;
}

- (IBAction)cycleFlash:(UIButton*)sender
{
    if(sender.selected) {
        
        sender.enabled = NO;
        sender.selected = NO;
    }
    else {
        
        sender.selected = YES;
    }
}

- (IBAction)setAutoFlash:(id)sender
{
    self.cameraButton.enabled = YES;
    self.cameraButton.selected = NO;
}

@end
