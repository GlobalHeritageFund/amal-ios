//
//  PassphraseViewController.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/7/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "PassphraseViewController.h"
#import "FormView.h"
#import "FormElements.h"
#import "PassphraseUnlockDeterminer.h"

@interface PassphraseViewController ()

@end

@implementation PassphraseViewController
@dynamic view;

- (void)loadView {
    self.view = [[FormView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    TextFormElement *textFormElement = [[TextFormElement alloc] initWithPlaceholder:@"Enter Passphrase" initialText:@""];
    
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Passphrase"
      formElements:@[
                     textFormElement,
                     [[ButtonFormElement alloc] initWithTitle:@"Submit" block:^{
         
        PassphraseUnlockStatus unlockStatus = [[[PassphraseUnlockDeterminer alloc] init] unlockStatusForPassphaseAttempt:textFormElement.textField.text];
         
         
     }],
                     ]
      ]
     ];
    
}

@end
