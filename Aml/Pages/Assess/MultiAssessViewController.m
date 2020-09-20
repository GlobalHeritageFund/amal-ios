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
    NSAssert(photos.count != 0, @"MultiAssessViewController requires at least one photo");
    _photos = photos;

    self.hazardsSwitchElement = [[SwitchFormElement alloc] initWithTitle:NSLocalizedString(@"switch-label.hazards", @"A label for a switch to determine if there are hazards in the area of the assessed object.")];
    self.safetySwitchElement = [[SwitchFormElement alloc] initWithTitle:NSLocalizedString(@"switch-label.personal-hazard", @"A label for a switch to determine if there is a safety hazard in the area of the assessed object.")];
    self.interventionSwitchElement = [[SwitchFormElement alloc] initWithTitle:NSLocalizedString(@"switch-label.intervention", @"A label for a switch to determine if intervention is recommended for the assessed object.")];

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

    self.title = NSLocalizedString(@"header.batch-assess", @"A heading for the screen to assess multiple objects.");

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
      initWithHeaderText:NSLocalizedString(@"Name", @"A header for a section for the name of the object.")
      formElements:@[
                     [self newNameFormElement],
                     ]]
     ];

    if ([self.photos anyObjectsPassTest:^BOOL(LocalPhoto *photo) { return photo.metadata.hasLocationCoordinates; }]) {
        [self.view addFormGroup:
         [[FormGroup alloc]
          initWithHeaderText:NSLocalizedString(@"header.map", @"A header for a section for the location of the object.")
          formElements:@[
                         [self newMapFormElement],
                         ]]
         ];
    }

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"header.category", @"A header for a section for the category of the object.")
      formElements:@[
                    [self newCategoryFormElement],
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"header.condition", @"A header for a section for the condition of the object.")
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
      initWithHeaderText:NSLocalizedString(@"header.assess", @"A header for a section for the hazards of the object.")
      formElements:@[
                     self.hazardsSwitchElement,
                     self.safetySwitchElement,
                     self.interventionSwitchElement,
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"header.notes", @"A header for a section for any notes about the object.")
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

    TextFormElement *nameFormElement = [[TextFormElement alloc] initWithPlaceholder:NSLocalizedString(@"Name", @"A label for a text field for the name of the object.") initialText:initialText];
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
        NSLocalizedString(@"object-type.area", @"A control to set the object's category to 'area'."),
        NSLocalizedString(@"object-type.site", @"A control to set the object's category to 'site' or 'building'."),
        NSLocalizedString(@"object-type.object", @"A control to set the object's category to 'object'."),
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
    NSString *key = NSLocalizedString(@"warning.delete-photos.interpolation", @"A warning that appears when you want to delete one or more photos. #bc-ignore!");
    NSString *message = [NSString localizedStringWithFormat:key, self.photos.count];

    [FIRAnalytics logEventWithName:@"single_delete" parameters:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"header.are-you-sure", @"A title for a warning asking if the user is sure they want to delete some photos.") message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.delete", @"A standard delete button.") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        for (LocalPhoto *photo in self.photos) {
            [photo removeLocalData];
        }
        [self.navigationController popViewControllerAnimated:true];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", @"A standard cancel button.") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (CLLocationCoordinate2D)coordinateMidpoint {
    NSNumber *averageLatitude = [[[self.photos valueForKeyPath:@"metadata.latitude"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != 0"]] valueForKeyPath:@"@avg.self"];
    NSNumber *averageLongitude = [[[self.photos valueForKeyPath:@"metadata.longitude"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != 0"]] valueForKeyPath:@"@avg.self"];
    return CLLocationCoordinate2DMake(averageLatitude.doubleValue, averageLongitude.doubleValue);
}

@end
