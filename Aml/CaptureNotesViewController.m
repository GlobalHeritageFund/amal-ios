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

@interface CaptureNotesViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) LocalPhoto *photo;
@property (nonatomic) NSMutableArray *formGroups;

@end

@implementation CaptureNotesViewController

- (instancetype)initWithPhoto:(LocalPhoto *)photo {
    self = [super init];
    if (!self) {
        return nil;
    }
    _photo = photo;
    return self;
}

- (NSMutableArray *)formGroups {
    if (!_formGroups) {
        _formGroups = [@[] mutableCopy];
    }
    return _formGroups;
}


- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.alwaysBounceVertical = true;
        scrollView.backgroundColor = [UIColor colorWithHex:0xEFEFF4];
        [self.view addSubview:scrollView];
        self.scrollView = scrollView;
    }
    return _scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Capture Notes";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteTapped:)];

    [self addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Photo"
      formElements:@[
                     [[PhotoFormElement alloc] initWithImage:self.photo.image],
                     ]]
     ];

    [self addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Category"
      formElements:@[
                     [[SegmentedControlFormElement alloc] initWithTitles:@[@"Overall Area", @"Site / Building", @"Object"]],
                     ]]
     ];

    [self addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Level of Damage"
      formElements:@[
                     [[DamageButtonFormElement alloc] init],
                     ]
      ]];

    [self addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Assess"
      formElements:@[
                     [[SwitchFormElement alloc] initWithTitle:@"Hazards"],
                     [[SwitchFormElement alloc] initWithTitle:@"Safety Hazards"],
                     [[SwitchFormElement alloc] initWithTitle:@"Intervention Recommended"],
                     ]]
     ];

    [self addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Notes"
      formElements:@[
                     [[NotesFormElement alloc] init],
                     ]]
     ];
}

- (void)addFormGroup:(FormGroup *)formGroup {
    [self.scrollView addSubview:formGroup];
    [self.formGroups addObject:formGroup];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [[self.formGroups valueForKeyPath:@"@sum.expectedHeight"] floatValue]);
    CGRect workingRect = self.view.bounds;
    workingRect.size.height = self.scrollView.contentSize.height;
    for (FormGroup *group in self.formGroups) {
        CGRect groupRect = CGRectZero;
        CGRectDivide(workingRect, &groupRect, &workingRect, group.expectedHeight, CGRectMinYEdge);
        group.frame = groupRect;
    }
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

@end
