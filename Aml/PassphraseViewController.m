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
#import "PassphraseValidator.h"
#import "NSObject+Helpers.h"
#import "CurrentUser.h"

@interface PassphraseViewController ()

@end

@implementation PassphraseViewController
@dynamic view;

- (void)loadView {
    self.view = [[FormView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Enter a partner code";

    TextFormElement *textFormElement = [[TextFormElement alloc] initWithPlaceholder:@"Enter partner code" initialText:@""];
    
    __weak typeof(self) weakSelf = self;
    
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Partner code"
      formElements:@[
                     textFormElement,
                     [[ButtonFormElement alloc] initWithTitle:@"Submit" block:^{
         
         Promise *promise = [[[PassphraseValidator alloc] init] unlockStatusForPassphaseAttempt:textFormElement.textField.text];
         [[promise then:^id _Nullable(id  _Nonnull object) {
             NSNumber *number = [object asClassOrNil:[NSNumber class]];
             
             if (number) {
                 PassphraseUnlockStatus status = number.integerValue;
                 
                 if (status == PassphraseUnlockStatusEAMENA) {
                     [CurrentUser shared].isEAMENAEnabled = YES;
                     
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success!" message:@"You have unlocked HerBridge" preferredStyle:UIAlertControllerStyleAlert];
                     [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                         [weakSelf.navigationController popViewControllerAnimated:YES];
                     }]];
                     [weakSelf presentViewController:alertController animated:YES completion:nil];
                 }
                 
             }
             
             return nil;
         }] catch:^(NSError * _Nonnull error) {
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"This partner code is not correct" preferredStyle:UIAlertControllerStyleAlert];
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
