//
//  SettingsViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 12/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

@import FirebaseAuth;
#import "SettingsViewController.h"
#import "FormElements.h"
#import "CurrentUser.h"
#import "Firebase+Promises.h"
#import "PassphraseViewController.h"

@interface SettingsViewController ()

@property (nonatomic, weak) id <SettingsViewControllerDelegate>delegate;

@end

@implementation SettingsViewController

@dynamic view;

- (instancetype)initWithDelegate:(id <SettingsViewControllerDelegate>)delegate {
    self = [super init];
    
    if (self) {
        _delegate = delegate;
    }

    return self;
}

- (void)loadView {
    self.view = [[FormView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Settings", @"A heading for the Settings screen.");

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setupForm];
}

- (void)setupForm {
    [self.view resetForm];
    
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"About AMAL", @"A header for a section that describes the Amal project.")
      formElements:@[
          [[MultiLineLabelFormElement alloc] initWithText:NSLocalizedString(@"AMAL is an emergency management application designed for the rapid impact assessment of cultural heritage areas, buildings, and artifacts.", @"A description of the Amal project.")],
      ]
      ]
     ];
    
    
    NSDictionary *bundleDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"%@b%@", [bundleDict valueForKey:@"CFBundleShortVersionString"], [bundleDict valueForKey:(NSString*)kCFBundleVersionKey]];
    
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"Version", @"A header for a section that shows the app's version.")
      formElements:@[
          [[TextFormElement alloc] initWithImmutableText:version],
      ]
      ]
     ];
    
    
    
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"Visit", @"A header for a section that shows web links for Amal.")
      formElements:@[
          [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"Visit amal.global", @"A button that directs the user to the Amal web site.") block:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://amal.global/"]];
    }],
          [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"User Guide", @"A button that directs the user to the Amal user guide.") block:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://amal.global/guide"]];
    }],
          [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"Privacy Policy", @"A button that directs the user to the Amal privacy policy.") block:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://globalheritagefund.org/index.php/news-resources/library/privacy-policy/"]];

    }],
          [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"Terms of Service", @"A button that directs the user to the Amal terms of service.") block:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://amal.global/terms-of-service/"]];

    }],
      ]
      ]
     ];
    
    CurrentUser *user = [CurrentUser shared];
    
    __weak typeof(self) weakSelf = self;
    
    ButtonFormElement *authenticationElement = ^ButtonFormElement *(){
        if (user.isLoggedIn) {
            return [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"Log out", @"A header for a button that logs the user out.") block:^{
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", @"A title for a warning asking if the user is sure they want to log out.") message:NSLocalizedString(@"Are you sure you want to log out?", @"A warning asking if the user is sure they want to log out.") preferredStyle:UIAlertControllerStyleActionSheet];
                
                [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Log out", @"A button that logs the user out.") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [user signOut];
                    [weakSelf setupForm];
                }]];
                
                [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"A standard cancel button.") style:UIAlertActionStyleCancel handler:nil]];
                
                [weakSelf presentViewController:controller animated:YES completion:nil];
            }];
        } else {
            return [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"Log in", @"A header for a button that logs the user in.") block:^{
                FUIAuth *auth = [FUIAuth defaultAuthUI];
                [[auth signInPromise] then:^id _Nullable(id  _Nonnull object) {
                    [weakSelf setupForm];
                    return nil;
                }];
                UINavigationController *controller = [auth authViewController];
                [weakSelf presentViewController:controller animated:YES completion:nil];
            }];
        }
    }();

    [self.view addFormGroup:[[FormGroup alloc] initWithHeaderText:NSLocalizedString(@"Account", @"A header for a section that shows the user's account information.") formElements:@[authenticationElement]]];

    NSMutableArray *partnerElements = [NSMutableArray array];

    if ([CurrentUser shared].isEAMENAUnlocked) {
        [partnerElements addObject:[[TextFormElement alloc] initWithImmutableText:NSLocalizedString(@"EAMENA unlocked", @"A label indicating that the EAMENA database has been unlocked.")]];
    }

    if ([CurrentUser shared].isLebanonUnlocked) {
        [partnerElements addObject:[[TextFormElement alloc] initWithImmutableText:NSLocalizedString(@"Lebanon unlocked", @"A label indicating that the Lebanon database has been unlocked.")]];
    }

    [partnerElements addObject:[[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"Enter a new partner code", @"A button that allows the user to enter a password/code for a partner database.") block:^{
        [weakSelf.delegate didSelectEnterPassphrase];
    }]];

    [self.view addFormGroup:[[FormGroup alloc] initWithHeaderText:NSLocalizedString(@"Partners", @"A section that shows information about Amal partners.") formElements:partnerElements]];

    [self.view addFormGroup:[[FormGroup alloc] initWithHeaderText:NSLocalizedString(@"Acknowledgements", @"") formElements:@[
        [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"Acknowledgements", @"") block:^{
        [weakSelf.delegate didSelectAcknowledgements];
    }],
    ]]];
}

@end
