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
    
    self.title =  NSLocalizedString(@"header.partner-code", @"A header for a section about unlocking partner databases with a code/password.");

    TextFormElement *textFormElement = [[TextFormElement alloc] initWithPlaceholder:NSLocalizedString(@"header.partner-code", @"A description for a text field for a code/password to unlock a partner database.") initialText:@""];
    
    __weak typeof(self) weakSelf = self;
    
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"label.partner-code", @"A label for a form to unlock partner databases with a code/password.")
      formElements:@[
                     textFormElement,
                     [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"button.submit", @"A standard submit button.") block:^{
         
         Promise *promise = [[[PassphraseValidator alloc] init] unlockStatusForPassphraseAttempt:textFormElement.textField.text];
         [[promise then:^id _Nullable(id  _Nonnull object) {
             NSNumber *number = [object asClassOrNil:[NSNumber class]];
             
             if (number) {
                 PassphraseUnlockStatus status = number.integerValue;
                 
                 if (status == PassphraseUnlockStatusEAMENA) {
                     [CurrentUser shared].isEAMENAUnlocked = YES;
                     
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"header.partner-database-unlocked", @"A title for a warning informing the user that they've unlocked a database.") message:NSLocalizedString(@"label.eamena-unlocked", @"Informs the user that they've unlocked a database") preferredStyle:UIAlertControllerStyleAlert];
                     [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.ok", @"A standard OK button.") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                         [weakSelf.navigationController popViewControllerAnimated:YES];
                     }]];
                     [weakSelf presentViewController:alertController animated:YES completion:nil];
                 } else if (status == PassphraseUnlockStatusLebanon) {
                     [CurrentUser shared].isLebanonUnlocked = YES;
                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"header.partner-database-unlocked", @"A title for a warning informing the user that they've unlocked a database.") message:NSLocalizedString(@"label.lebanon-unlocked", @"Informs the user that they've unlocked a database") preferredStyle:UIAlertControllerStyleAlert];
                     [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.ok", @"A standard OK button.") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                         [weakSelf.navigationController popViewControllerAnimated:YES];
                     }]];
                     [weakSelf presentViewController:alertController animated:YES completion:nil];

                 }
                 
             }
             
             return nil;
         }] catch:^(NSError * _Nonnull error) {
             
             UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"header.partner-code-invalid", @"A title for a warning informing the user that their code/password was invalid.") message:NSLocalizedString(@"warning.database-password-invalid", @"A warning informing the users that their code/password was invalid.") preferredStyle:UIAlertControllerStyleAlert];
             [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.ok", @"A standard OK button.") style:UIAlertActionStyleDefault handler:nil]];
             [weakSelf presentViewController:alertController animated:YES completion:nil];
         }];
    }],
      ]
      ]
     ];
    
}

@end
