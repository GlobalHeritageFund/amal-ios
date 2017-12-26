//
//  SettingsViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 12/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "SettingsViewController.h"
#import "FormElements.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@dynamic view;

- (void)loadView {
    self.view = [[FormView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Settings";

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"About AMAL"
      formElements:@[
                     [[TextFormElement alloc] initWithImmutableText:@"Woo"],
                     ]
      ]
     ];


    NSDictionary *bundleDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"%@b%@", [bundleDict valueForKey:@"CFBundleShortVersionString"], [bundleDict valueForKey:(NSString*)kCFBundleVersionKey]];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Version"
      formElements:@[
                     [[TextFormElement alloc] initWithImmutableText:version],
                     ]
      ]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Visit"
      formElements:@[
                     [[TextFormElement alloc] initWithImmutableText:@"Visit amal.global."],
                     [[TextFormElement alloc] initWithImmutableText:@"View the privacy policy."],
                     [[TextFormElement alloc] initWithImmutableText:@"View the terms of service."],
                     ]
      ]
     ];


}

@end
