//
//  CaptureNotesViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "CaptureNotesViewController.h"
#import "LocalPhoto.h"
#import "NotesForm.h"
#import "UIColor+Additions.h"
#import "ImageDetailViewController.h"

@interface CaptureNotesViewController ()

@property (nonatomic, strong) LocalPhoto *photo;

@end

@implementation CaptureNotesViewController

@dynamic view;

- (instancetype)initWithPhoto:(LocalPhoto *)photo {
    self = [super init];
    if (!self) {
        return nil;
    }
    _photo = photo;
    return self;
}

- (void)loadView {
    self.view = [[CaptureNotesView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Capture Notes";

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteTapped:)];

    PhotoFormElement *photoElement = [[PhotoFormElement alloc] initWithImage:self.photo.image];
    photoElement.imageView.userInteractionEnabled = YES;
    [photoElement.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)]];
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Photo"
      formElements:@[
                     photoElement,
                     ]]
     ];

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


- (void)deleteTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"Are you sure you want to delete this photo? This can not be undone." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [self.photo unsync];
        [self.photo removeLocalData];
        [self.navigationController popViewControllerAnimated:true];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)photoTapped:(UITapGestureRecognizer *)sender {
    ImageDetailViewController *imageDetail = [[ImageDetailViewController alloc] init];
    [imageDetail loadViewIfNeeded];
    imageDetail.imageView.image = self.photo.image;
    [self.navigationController pushViewController:imageDetail animated:YES];

}

@end
