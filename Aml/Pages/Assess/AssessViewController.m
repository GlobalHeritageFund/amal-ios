//
//  AssessViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "AssessViewController.h"
#import "LocalPhoto.h"
#import "FormElements.h"
#import "UIColor+Additions.h"
#import "ImageDetailViewController.h"
#import "AMLMetadata.h"
#import "MapViewController.h"
#import "Firebase.h"

@interface AssessViewController ()

@property (nonatomic, strong) LocalPhoto *photo;
@property (nonatomic) SwitchFormElement *hazardsSwitchElement;
@property (nonatomic) SwitchFormElement *safetySwitchElement;
@property (nonatomic) SwitchFormElement *interventionSwitchElement;

@end

@implementation AssessViewController

@dynamic view;

- (instancetype)initWithPhoto:(LocalPhoto *)photo {
    self = [super init];
    if (!self) {
        return nil;
    }
    _photo = photo;

    self.hazardsSwitchElement = [[SwitchFormElement alloc] initWithTitle:NSLocalizedString(@"switch-label.hazards", @"A label for a switch to determine if there are hazards in the area of the assessed object.")];
    self.safetySwitchElement = [[SwitchFormElement alloc] initWithTitle:NSLocalizedString(@"switch-label.personal-hazard", @"A label for a switch to determine if there is a safety hazard in the area of the assessed object.")];
    self.interventionSwitchElement = [[SwitchFormElement alloc] initWithTitle:NSLocalizedString(@"switch-label.intervention", @"A label for a switch to determine if intervention is recommended for the assessed object.")];

    [self.photo refreshMetadata];

    return self;
}

- (void)loadView {
    self.view = [[FormView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"header.assess", @"A heading for the Assess screen.");

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
    
    self.hazardsSwitchElement.toggle.on = self.photo.metadata.hazards;
    self.safetySwitchElement.toggle.on = self.photo.metadata.safetyHazards;
    self.interventionSwitchElement.toggle.on = self.photo.metadata.interventionRequired;

    PhotoFormElement *photoElement = [[PhotoFormElement alloc] init];
    [[self.photo loadThumbnailImage] then:^id _Nullable(id  _Nonnull object) {
        photoElement.imageView.image = object;
        return nil;
    }];
    photoElement.imageView.userInteractionEnabled = YES;
    [photoElement.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)]];
    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:nil
      formElements:@[
                     photoElement,
                     ]]
     ];

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"Name", @"A header for a section for the name of the object.")
      formElements:@[
                     [self newNameFormElement],
                     ]]
     ];

    if (self.photo.metadata.hasLocationCoordinates) {
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

    NSMutableArray<UIView<FormElement> *> *formElements = [@[] mutableCopy];
    if (self.photo.metadata.hasLocationCoordinates) {
        TextFormElement *latLong = [[TextFormElement alloc] init];
        latLong.textField.text = self.photo.metadata.locationString;
        latLong.textField.enabled = NO;
        [formElements addObject:latLong];

        __weak __typeof(&*self)weakSelf = self;
        ButtonFormElement *element = [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"button.edit-location", @"A button label to adjust the location of the object.") block:^{
            [weakSelf showEditableMap];
        }];
        [formElements addObject:element];
    } else {
        __weak __typeof(&*self)weakSelf = self;
        ButtonFormElement *element = [[ButtonFormElement alloc] initWithTitle:NSLocalizedString(@"button.set-location", @"A button label to set a location for an unlocated object.") block:^{
            [weakSelf showEditableMap];
        }];
        [formElements addObject:element];
    }

    [self.view addFormGroup:
     [[FormGroup alloc]
      initWithHeaderText:NSLocalizedString(@"header.coordinates", @"A header for a section for the GPS coordinates of the object.")
      formElements:formElements]
     ];

}

- (TextFormElement *)newNameFormElement {
    TextFormElement *nameFormElement = [[TextFormElement alloc] initWithPlaceholder:NSLocalizedString(@"Name", @"A label for a text field for the name of the object.") initialText:self.photo.metadata.name];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nameFieldDidChange:) name:UITextFieldTextDidEndEditingNotification object:nameFormElement.textField];
    return nameFormElement;
}

- (void)nameFieldDidChange:(NSNotification *)notification {
    UITextField *textField = notification.object;
    NSString *newName = textField.text ?: @"";
    if ([self.photo.metadata.name isEqualToString:@""]) {
        [FIRAnalytics logEventWithName:@"metadata_added_name" parameters:@{ @"new_name": newName }];
    } else {
        [FIRAnalytics logEventWithName:@"metadata_updated_name" parameters:@{ @"new_name": newName }];
    }
    self.photo.metadata.name = newName;
    [self saveMetadata];
}

- (MapFormElement *)newMapFormElement {
    MapFormElement *mapFormElement = [[MapFormElement alloc] initWithCoordinate:self.photo.metadata.coordinate];
    [mapFormElement addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)]];
    return mapFormElement;
}

- (void)mapTapped:(id)sender {
    [FIRAnalytics logEventWithName:@"map_detail_tapped" parameters:nil];
    MapViewController *mapViewController = [[MapViewController alloc] initWithPhotos:@[self.photo]];
    [self.navigationController pushViewController:mapViewController animated:YES];
}

- (TextViewFormElement *)newNotesFormElement {
    TextViewFormElement *notesFormElement = [[TextViewFormElement alloc] init];
    notesFormElement.textView.text = self.photo.metadata.notes;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notesFieldDidChange:) name:UITextViewTextDidChangeNotification object:notesFormElement.textView];
    return notesFormElement;
}

- (void)notesFieldDidChange:(NSNotification *)notification {
    UITextView *textView = notification.object;
    [FIRAnalytics logEventWithName:@"metadata_updated_notes" parameters:nil];
    self.photo.metadata.notes = textView.text;
    [self saveMetadata];
}

- (SegmentedControlFormElement *)newCategoryFormElement {
    SegmentedControlFormElement *categoryFormElement = [[SegmentedControlFormElement alloc] initWithTitles:@[
        NSLocalizedString(@"object-type.area", @"A control to set the object's category to 'area'."),
        NSLocalizedString(@"object-type.site", @"A control to set the object's category to 'site' or 'building'."),
        NSLocalizedString(@"object-type.object", @"A control to set the object's category to 'object'."),
    ]];
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
    [FIRAnalytics logEventWithName:@"metadata_updated_category" parameters:@{ @"new_category": self.photo.metadata.category }];
    [self saveMetadata];
}

- (DamageButtonFormElement *)damageButtonElement {
    DamageButtonFormElement *damageButtonElement = [[DamageButtonFormElement alloc] init];
    [damageButtonElement addTarget:self action:@selector(levelOfDamageDidChange:) forControlEvents:UIControlEventValueChanged];
    damageButtonElement.selectedValue = self.photo.metadata.levelOfDamage;
    return damageButtonElement;
}

- (void)levelOfDamageDidChange:(DamageButtonFormElement *)damageButtonElement {
    self.photo.metadata.levelOfDamage = damageButtonElement.selectedValue;
    [self saveMetadata];
}

- (DamageButtonFormElement *)newConditionElement {
    DamageButtonFormElement *conditionElement = [[DamageButtonFormElement alloc] init];
    [conditionElement addTarget:self action:@selector(conditionDidChange:) forControlEvents:UIControlEventValueChanged];
    conditionElement.selectedValue = self.photo.metadata.conditionNumber;
    return conditionElement;
}

- (void)conditionDidChange:(DamageButtonFormElement *)damageButtonElement {
    self.photo.metadata.conditionNumber = damageButtonElement.selectedValue;
    [FIRAnalytics logEventWithName:@"metadata_updated_condition" parameters:@{ @"new_condition": @(damageButtonElement.selectedValue) }];
    [self saveMetadata];
}

- (void)hazardsSwitchChanged:(UISwitch *)sender {
    [FIRAnalytics logEventWithName:@"metadata_updated_hazards" parameters:nil];
    self.photo.metadata.hazards = sender.isOn;
    [self saveMetadata];
}

- (void)safetySwitchChanged:(UISwitch *)sender {
    [FIRAnalytics logEventWithName:@"metadata_updated_safety" parameters:nil];
    self.photo.metadata.safetyHazards = sender.isOn;
    [self saveMetadata];
}

- (void)interventionSwitchChanged:(UISwitch *)sender {
    [FIRAnalytics logEventWithName:@"metadata_updated_intervention" parameters:nil];
    self.photo.metadata.interventionRequired = sender.isOn;
    [self saveMetadata];
}

- (void)saveMetadata {
    [FIRAnalytics logEventWithName:@"assessed_image" parameters:nil];
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
    [FIRAnalytics logEventWithName:@"single_delete" parameters:nil];
    NSString *key = NSLocalizedString(@"warning.delete-photos.interpolation", @"A warning that appears when you want to delete one or more photos. #bc-ignore!");
    NSString *message = [NSString localizedStringWithFormat:key, 1];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"header.are-you-sure", @"A title for a warning asking if the user is sure they want to delete some photos.") message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.delete", @"A standard delete button.") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self.photo removeLocalData];
        [self.navigationController popViewControllerAnimated:true];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"button.cancel", @"A standard cancel button.") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)photoTapped:(UITapGestureRecognizer *)sender {
    [FIRAnalytics logEventWithName:@"full_screen_image" parameters:nil];
    ImageDetailViewController *imageDetail = [[ImageDetailViewController alloc] init];
    [[self.photo loadFullSizeImage] then:^id _Nullable(id  _Nonnull fullSize) {
        imageDetail.imageView.image = fullSize;
        return nil;
    }];
    [self.navigationController pushViewController:imageDetail animated:YES];
}

- (void)showEditableMap {
    [self.delegate assessViewControllerDidTapEditCoordinates:self];
}

@end
