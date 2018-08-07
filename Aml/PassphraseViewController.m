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
#import "NSObject+Helpers.h"

@interface PassphraseViewController ()

@end

@implementation PassphraseViewController
@dynamic view;

- (void)loadView {
    self.view = [[FormView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Enter a Passphrase";

    TextFormElement *textFormElement = [[TextFormElement alloc] initWithPlaceholder:@"Enter Passphrase" initialText:@""];
    
    __weak typeof(self) weakSelf = self;
    
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Passphrase"
      formElements:@[
                     textFormElement,
                     [[ButtonFormElement alloc] initWithTitle:@"Submit" block:^{
         
         Promise *promise = [[[PassphraseUnlockDeterminer alloc] init] unlockStatusForPassphaseAttempt:textFormElement.textField.text];
         [[promise then:^id _Nullable(id  _Nonnull object) {
             NSNumber *number = [object asClassOrNil:[NSNumber class]];
             
             if (number) {
                 PassphraseUnlockStatus status = number.integerValue;
                 
             }
             
             return nil;
         }] catch:^(NSError * _Nonnull error) {
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"This passphrase is not correct" preferredStyle:UIAlertControllerStyleAlert];
             [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
             [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
             [weakSelf presentViewController:alertController animated:YES completion:nil];
         }];
     }],
                     ]
      ]
     ];
    
}

@end
