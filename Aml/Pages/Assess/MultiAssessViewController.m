//
//  AssessViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "MultiAssessViewController.h"
#import "LocalPhoto.h"
#import "FormElements.h"
#import "UIColor+Additions.h"
#import "ImageDetailViewController.h"
#import "AMLMetadata.h"
#import "MapViewController.h"
#import "Firebase.h"
#import "NSArray+Additions.h"

@interface MultiAssessViewController ()

@property (nonatomic, strong) NSArray<LocalPhoto *> *photos;
@property (nonatomic) SwitchFormElement *hazardsSwitchElement;
@property (nonatomic) SwitchFormElement *safetySwitchElement;
@property (nonatomic) SwitchFormElement *interventionSwitchElement;

@end

@implementation MultiAssessViewController

@dynamic view;

- (instancetype)initWithPhotos:(NSArray<LocalPhoto *> *)photos {
    self = [super init];
    if (!self) return nil;
    NSAssert(photos.count != 0, @"MultiAsessViewController requires at least one photo");
    _photos = photos;

    self.hazardsSwitchElement = [[SwitchFormElement alloc] initWithTitle:NSLocalizedString(@"Hazards", @"")];
    self.safetySwitchElement = [[SwitchFormElement alloc] initWithTitle:NSLocalizedString(@"Safety/Personal Hazard", @"")];
    self.interventionSwitchElement = [[SwitchFormElement alloc] initWithTitle:NSLocalizedString(@"Intervention Recommended", @"")];

    for (LocalPhoto *photo in self.photos) {
        [photo refreshMetadata];
    }

    return self;
}

- (void)loadView {
    self.view = [[FormView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Batch Assess", @"");

    [self.hazardsSwitchElement.toggle addTarget:self action:@selector(hazardsSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.safetySwitchElement.toggle addTarget:self action:@selector(safetySwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.interventionSwitchElement.toggle addTarget:self action:@selector(interventionSwitchChanged:) forControlEvents:UIControlEventValueChanged];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteTapped:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self renderForm];
}

- (void)renderForm {
    [self.view resetForm];
    
    self.hazardsSwitchElement.toggle.on = [self.photos allObjectsPassTest:^BOOL(LocalPhoto *photo) {
        return photo.metadata.hazards;
    }];

    self.safetySwitchElement.toggle.on = [self.photos allObjectsPassTest:^BOOL(LocalPhoto *photo) {
        return photo.metadata.safetyHazards;
    }];

    self.interventionSwitchElement.toggle.on = [self.photos allObjectsPassTest:^BOOL(LocalPhoto *photo) {
        return photo.metadata.interventionRequired;
    }];;

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:@"Name"
      formElements:@[
                     [self newNameFormElement],
                     ]]
     ];

    if ([self.photos anyObjectsPassTest:^BOOL(LocalPhoto *photo) { return photo.metadata.hasLocationCoordinates; }]) {
        [self.view addFormGroup:
         [[FormGroup alloc]
          initWithHeaderText:NSLocalizedString(@"Map", @"")
          formElements:@[
                         [self newMapFormElement],
                         ]]
         ];
    }

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"Category", @"")
      formElements:@[
                    [self newCategoryFormElement],
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"Overall Condition", @"")
      formElements:@[
                     [self newConditionElement],
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
      initWithHeaderText:NSLocalizedString(@"Assess", @"")
      formElements:@[
                     self.hazardsSwitchElement,
                     self.safetySwitchElement,
                     self.interventionSwitchElement,
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"Notes", @"")
      formElements:@[
                     [self newNotesFormElement],
                     ]]
     ];

}

- (TextFormElement *)newNameFormElement {
    NSString *initialText = @"";
    if ([[self.photos valueForKeyPath:@"metadata.name"] allObjectsEqual]) {
        initialText = self.photos.firstObject.metadata.name;
    }

    TextFormElement *nameFormElement = [[TextFormElement alloc] initWithPlaceholder:NSLocalizedString(@"Name", @"") initialText:initialText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nameFieldDidChange:) name:UITextFieldTextDidEndEditingNotification object:nameFormElement.textField];
    return nameFormElement;
}

- (void)nameFieldDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    NSString *newName = textField.text ?: @"";

    [self mutatingEachPhoto:^(LocalPhoto *photo) {
        photo.metadata.name = newName;
    }];
}

- (MapFormElement *)newMapFormElement {
    MapFormElement *mapFormElement = [[MapFormElement alloc] initWithCoordinate:[self coordinateMidpoint]];
    [mapFormElement addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)]];
    return mapFormElement;
}

- (void)mapTapped:(id)sender {
    [FIRAnalytics logEventWithName:@"map_detail_tapped" parameters:nil];
    MapViewController *mapViewController = [[MapViewController alloc] initWithPhotos:self.photos];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (TextViewFormElement *)newNotesFormElement {
    TextViewFormElement *notesFormElement = [[TextViewFormElement alloc] init];

    NSString *initialText = @"";
    if ([[self.photos valueForKeyPath:@"metadata.notes"] allObjectsEqual]) {
        initialText = self.photos.firstObject.metadata.notes;
    }
    notesFormElement.textView.text = initialText;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notesFieldDidChange:) name:UITextViewTextDidChangeNotification object:notesFormElement.textView];
    return notesFormElement;
}

- (void)notesFieldDidChange:(NSNotification *)notification {
    UITextView *textView = notification.object;

    [self mutatingEachPhoto:^(LocalPhoto *photo) {
        photo.metadata.notes = textView.text;
    }];
}

- (SegmentedControlFormElement *)newCategoryFormElement {
    SegmentedControlFormElement *categoryFormElement = [[SegmentedControlFormElement alloc] initWithTitles:@[
        NSLocalizedString(@"Overall Area", @""),
        NSLocalizedString(@"Site / Building", @""),
        NSLocalizedString(@"Object", @""),
    ]];
    UISegmentedControl *segmentedControl = categoryFormElement.segmentedControl;
    [segmentedControl addTarget:self action:@selector(categoryDidChange:) forControlEvents:UIControlEventValueChanged];
    if ([[self.photos valueForKeyPath:@"metadata.category"] allObjectsEqual]) {
        if ([self.photos.firstObject.metadata.category isEqual:@"area"]) {
            segmentedControl.selectedSegmentIndex = 0;
        }
        if ([self.photos.firstObject.metadata.category isEqual:@"site"]) {
            segmentedControl.selectedSegmentIndex = 1;
        }
        if ([self.photos.firstObject.metadata.category isEqual:@"object"]) {
            segmentedControl.selectedSegmentIndex = 2;
        }
    }
    return categoryFormElement;
}


- (void)categoryDidChange:(UISegmentedControl *)segmentedControl {
    NSString *newCategory = @"";
    if (segmentedControl.selectedSegmentIndex == 0) {
        newCategory = @"area";
    }
    if (segmentedControl.selectedSegmentIndex == 1) {
        newCategory = @"site";
    }
    if (segmentedControl.selectedSegmentIndex == 2) {
        newCategory = @"object";
    }
    [self mutatingEachPhoto:^(LocalPhoto *photo) {
        photo.metadata.category = newCategory;
    }];
}

- (DamageButtonFormElement *)damageButtonElement {
    DamageButtonFormElement *damageButtonElement = [[DamageButtonFormElement alloc] init];
    [damageButtonElement addTarget:self action:@selector(levelOfDamageDidChange:) forControlEvents:UIControlEventValueChanged];
    if ([[self.photos valueForKeyPath:@"metadata.levelOfDamage"] allObjectsEqual]) {
        damageButtonElement.selectedValue = self.photos.firstObject.metadata.levelOfDamage;
    }
    return damageButtonElement;
}

- (void)levelOfDamageDidChange:(DamageButtonFormElement *)damageButtonElement {
    [self mutatingEachPhoto:^(LocalPhoto *photo) {
        photo.metadata.levelOfDamage = damageButtonElement.selectedValue;
    }];
}

- (DamageButtonFormElement *)newConditionElement {
    DamageButtonFormElement *conditionElement = [[DamageButtonFormElement alloc] init];
    [conditionElement addTarget:self action:@selector(conditionDidChange:) forControlEvents:UIControlEventValueChanged];
    if ([[self.photos valueForKeyPath:@"metadata.conditionNumber"] allObjectsEqual]) {
        conditionElement.selectedValue = self.photos.firstObject.metadata.conditionNumber;
    }
    return conditionElement;
}

- (void)conditionDidChange:(DamageButtonFormElement *)damageButtonElement {
    [self mutatingEachPhoto:^(LocalPhoto *photo) {
        photo.metadata.conditionNumber = damageButtonElement.selectedValue;
    }];
}

- (void)hazardsSwitchChanged:(UISwitch *)sender {
    [self mutatingEachPhoto:^(LocalPhoto *photo) {
        photo.metadata.hazards = sender.isOn;
    }];
}

- (void)safetySwitchChanged:(UISwitch *)sender {
    [self mutatingEachPhoto:^(LocalPhoto *photo) {
        photo.metadata.safetyHazards = sender.isOn;
    }];
}

- (void)interventionSwitchChanged:(UISwitch *)sender {
    [self mutatingEachPhoto:^(LocalPhoto *photo) {
        photo.metadata.interventionRequired = sender.isOn;
    }];
}

- (void)mutatingEachPhoto:(void (^)(LocalPhoto *))block {
    for (LocalPhoto *photo in self.photos) {
        block(photo);
        [photo saveMetadata];
    }
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
    [FIRAnalytics logEventWithName:@"single_delete" parameters:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", @"") message:NSLocalizedString(@"Are you sure you want to delete these photos? This can not be undone.", @"") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        for (LocalPhoto *photo in self.photos) {
            [photo removeLocalData];
        }
        [self.navigationController popViewControllerAnimated:true];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (CLLocationCoordinate2D)coordinateMidpoint {
    NSNumber *averageLatitude = [[[self.photos valueForKeyPath:@"metadata.latitude"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != 0"]] valueForKeyPath:@"@avg.self"];
    NSNumber *averageLongitude = [[[self.photos valueForKeyPath:@"metadata.longitude"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != 0"]] valueForKeyPath:@"@avg.self"];
    return CLLocationCoordinate2DMake(averageLatitude.doubleValue, averageLongitude.doubleValue);
}

@end
