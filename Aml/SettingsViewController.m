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
                     [[MultiLineLabelFormElement alloc] initWithText:@"AMAL is a mobile and web application designed for the rapid impact assessment of damaged heritage areas, buildings, or artifacts."],
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
                     [[ButtonFormElement alloc] initWithTitle:@"Visit amal.global" block:^{
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://amal.global/"]];
     }],
                     [[ButtonFormElement alloc] initWithTitle:@"Privacy Policy" block:^{
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://globalheritagefund.org/index.php/news-resources/library/privacy-policy/"]];

     }],
                     [[ButtonFormElement alloc] initWithTitle:@"Terms of Service" block:^{
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://amal.global/terms-of-service/"]];

     }],
                     ]
      ]
     ];


}

@end