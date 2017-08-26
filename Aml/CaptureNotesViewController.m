//
//  CaptureNotesViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "CaptureNotesViewController.h"
#import "LocalPhoto.h"
#import "NotesForm.h"
#import "UIColor+Additions.h"
#import "ImageDetailViewController.h"
#import "AMLMetadata.h"
#import "MapViewController.h"

@interface CaptureNotesViewController ()

@property (nonatomic, strong) LocalPhoto *photo;
@property (nonatomic) SwitchFormElement *hazardsSwitchElement;
@property (nonatomic) SwitchFormElement *safetySwitchElement;
@property (nonatomic) SwitchFormElement *interventionSwitchElement;

@end

@implementation CaptureNotesViewController

@dynamic view;

- (instancetype)initWithPhoto:(LocalPhoto *)photo {
    self = [super init];
    if (!self) {
        return nil;
    }
    _photo = photo;

    self.hazardsSwitchElement = [[SwitchFormElement alloc] initWithTitle:@"Hazards"];
    self.safetySwitchElement = [[SwitchFormElement alloc] initWithTitle:@"Safety/Personal Hazard"];
    self.interventionSwitchElement = [[SwitchFormElement alloc] initWithTitle:@"Intervention Recommended"];

    return self;
}

- (void)loadView {
    self.view = [[CaptureNotesView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Assess";

    [self.hazardsSwitchElement.toggle addTarget:self action:@selector(hazardsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.safetySwitchElement.toggle addTarget:self action:@selector(safetySwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.interventionSwitchElement.toggle addTarget:self action:@selector(interventionSwitchChanged:) forControlEvents:UIControlEventValueChanged];

    self.hazardsSwitchElement.toggle.on = self.photo.metadata.hazards;
    self.safetySwitchElement.toggle.on = self.photo.metadata.safetyHazards;
    self.interventionSwitchElement.toggle.on = self.photo.metadata.interventionRequired;

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
      initWithHeaderText:@"Name"
      formElements:@[
                     [self nameFormElement],
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Map"
      formElements:@[
                     [self mapFormElement],
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Category"
      formElements:@[
                    [self categoryFormElement],
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Overall Condition"
      formElements:@[
                     [self conditionElement],
                     ]
      ]];

//    [self.view addFormGroup:
//     [[FormGroup alloc]
//      initWithHeaderText:@"Level of Damage"
//      formElements:@[
//                     [self damageButtonElement],
//                     ]
//      ]];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Assess"
      formElements:@[
                     self.hazardsSwitchElement,
                     self.safetySwitchElement,
                     self.interventionSwitchElement,
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Notes"
      formElements:@[
                     [self notesFormElement],
                     ]]
     ];

    TextFormElement *latLong = [[TextFormElement alloc] init];
    latLong.textField.text = [NSString stringWithFormat:@"%f, %f", self.photo.metadata.latitude, self.photo.metadata.longitude];
    latLong.textField.enabled = NO;
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Coordinates"
      formElements:@[
                     latLong,
                     ]]
     ];

    NSDictionary *bundleDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [NSString stringWithFormat:@"%@b%@", [bundleDict valueForKey:@"CFBundleShortVersionString"], [bundleDict valueForKey:(NSString*)kCFBundleVersionKey]];
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:version
      formElements:@[]]
     ];
}

- (TextFormElement *)nameFormElement {
    TextFormElement *nameFormElement = [[TextFormElement alloc] initWithPlaceholder:@"Name" initialText:self.photo.metadata.name];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nameFieldDidChange:) name:UITextFieldTextDidEndEditingNotification object:nameFormElement.textField];
    return nameFormElement;
}

- (void)nameFieldDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    self.photo.metadata.name = textField.text;
    [self.photo saveMetadata];
}

- (MapFormElement *)mapFormElement {
    MapFormElement *mapFormElement = [[MapFormElement alloc] initWithCoordinate:self.photo.metadata.coordinate];
    [mapFormElement addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)]];
    return mapFormElement;
}

- (void)mapTapped:(id)sender {
    MapViewController *mapViewController = [[MapViewController alloc] initWithCoordinate:self.photo.metadata.coordinate];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (TextViewFormElement *)notesFormElement {
    TextViewFormElement *notesFormElement = [[TextViewFormElement alloc] init];
    notesFormElement.textView.text = self.photo.metadata.notes;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notesFieldDidChange:) name:UITextViewTextDidChangeNotification object:notesFormElement.textView];
    return notesFormElement;
}

- (void)notesFieldDidChange:(NSNotification *)notification {
    UITextView *textView = notification.object;
    self.photo.metadata.notes = textView.text;
    [self.photo saveMetadata];
}

- (SegmentedControlFormElement *)categoryFormElement {
    SegmentedControlFormElement *categoryFormElement = [[SegmentedControlFormElement alloc] initWithTitles:@[@"Overall Area", @"Site / Building", @"Object"]];
    UISegmentedControl *segmentedControl = categoryFormElement.segmentedControl;
    [segmentedControl addTarget:self action:@selector(categoryDidChange:) forControlEvents:UIControlEventValueChanged];
    if ([self.photo.metadata.category isEqual:@"area"]) {
        segmentedControl.selectedSegmentIndex = 0;
    }
    if ([self.photo.metadata.category isEqual:@"site"]) {
        segmentedControl.selectedSegmentIndex = 1;
    }
    if ([self.photo.metadata.category isEqual:@"object"]) {
        segmentedControl.selectedSegmentIndex = 2;
    }
    return categoryFormElement;
}


- (void)categoryDidChange:(UISegmentedControl *)segmentedControl {
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.photo.metadata.category = @"area";
    }
    if (segmentedControl.selectedSegmentIndex == 1) {
        self.photo.metadata.category = @"site";
    }
    if (segmentedControl.selectedSegmentIndex == 2) {
        self.photo.metadata.category = @"object";
    }
    [self.photo saveMetadata];
}

- (DamageButtonFormElement *)damageButtonElement {
    DamageButtonFormElement *damageButtonElement = [[DamageButtonFormElement alloc] init];
    [damageButtonElement addTarget:self action:@selector(levelOfDamageDidChange:) forControlEvents:UIControlEventValueChanged];
    damageButtonElement.selectedValue = self.photo.metadata.levelOfDamage;
    return damageButtonElement;
}

- (void)levelOfDamageDidChange:(DamageButtonFormElement *)damageButtonElement {
    self.photo.metadata.levelOfDamage = damageButtonElement.selectedValue;
    [self.photo saveMetadata];
}

- (DamageButtonFormElement *)conditionElement {
    DamageButtonFormElement *conditionElement = [[DamageButtonFormElement alloc] init];
    [conditionElement addTarget:self action:@selector(conditionDidChange:) forControlEvents:UIControlEventValueChanged];
    conditionElement.selectedValue = self.photo.metadata.conditionNumber;
    return conditionElement;
}

- (void)conditionDidChange:(DamageButtonFormElement *)damageButtonElement {
    self.photo.metadata.conditionNumber = damageButtonElement.selectedValue;
    [self.photo saveMetadata];
}

- (void)hazardsSwitchChanged:(UISwitch *)sender {
    self.photo.metadata.hazards = sender.isOn;
    [self.photo saveMetadata];
}

- (void)safetySwitchChanged:(UISwitch *)sender {
    self.photo.metadata.safetyHazards = sender.isOn;
    [self.photo saveMetadata];
}

- (void)interventionSwitchChanged:(UISwitch *)sender {
    self.photo.metadata.interventionRequired = sender.isOn;
    [self.photo saveMetadata];
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
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.photo removeLocalData];
        [self.navigationController popViewControllerAnimated:true];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)photoTapped:(UITapGestureRecognizer *)sender {
    ImageDetailViewController *imageDetail = [[ImageDetailViewController alloc] init];
    [[self.photo loadFullSizeImage] then:^id _Nullable(id  _Nonnull fullSize) {
        imageDetail.imageView.image = fullSize;
        return nil;
    }];
    [self.navigationController pushViewController:imageDetail animated:YES];

}

@end
