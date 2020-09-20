//
//  AcknowledgementsViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 8/30/20.
//  Copyright © 2020 Global Heritage Fund. All rights reserved.
//

#import "AcknowledgementsViewController.h"
#import "FormView.h"
#import "FormElements.h"

@interface AcknowledgementsViewController ()

@end

@implementation AcknowledgementsViewController

@dynamic view;

- (void)loadView {
    self.view = [[FormView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"header.acknowledgements", @"A heading for the Acknowledgements screen.");

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupForm];
}

- (void)setupForm {
    [self.view resetForm];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"header.funders", @"A header for a section about the funders of the app.")
      formElements:@[
          [[MultiLineLabelFormElement alloc] initWithText:@"Prince Claus Fund"],
          [[MultiLineLabelFormElement alloc] initWithText:@"The International Centre for the Study of the Preservation and Restoration of Cultural Property (ICCROM)"],
      ]
      ]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"header.localizations", @"A header for a section about localizations.")
      formElements:@[
          [[MultiLineLabelFormElement alloc] initWithText:@"Special thanks to Hossam Mahdy for the Arabic localization of Amal."],
      ]
      ]
     ];
}


@end
