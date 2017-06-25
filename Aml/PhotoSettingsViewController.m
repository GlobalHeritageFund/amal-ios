//
//  PhotoSettingsViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "PhotoSettingsViewController.h"
#import "LocalPhoto.h"
#import "NotesForm.h"
#import "UIColor+Additions.h"
#import "ImageDetailViewController.h"

@interface PhotoSettingsViewController ()

@end

@implementation PhotoSettingsViewController

@dynamic view;

- (void)loadView {
    self.view = [[CaptureNotesView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Capture Notes";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Category"
      formElements:@[
                     [[SegmentedControlFormElement alloc] initWithTitles:@[@"Overall Area", @"Site / Building", @"Object"]],
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Level of Damage"
      formElements:@[
                     [[DamageButtonFormElement alloc] init],
                     ]
      ]];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Assess"
      formElements:@[
                     [[SwitchFormElement alloc] initWithTitle:@"Hazards"],
                     [[SwitchFormElement alloc] initWithTitle:@"Safety Hazards"],
                     [[SwitchFormElement alloc] initWithTitle:@"Intervention Recommended"],
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Notes"
      formElements:@[
                     [[NotesFormElement alloc] init],
                     ]]
     ];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    [self moveTextViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [self moveTextViewForKeyboard:notification up:NO];
}

- (void)moveTextViewForKeyboard:(NSNotification*)notification up:(BOOL)up {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect;

    keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];

    UIEdgeInsets textViewInset = self.view.scrollView.contentInset;
    if (up == YES) {
        textViewInset.bottom = keyboardRect.size.height;
    } else {
        textViewInset.bottom = [self.bottomLayoutGuide length];
    }
    self.view.scrollView.contentInset = textViewInset;
    self.view.scrollView.scrollIndicatorInsets = textViewInset;
}

@end
