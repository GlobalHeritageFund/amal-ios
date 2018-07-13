//
//  FormElements.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "FormElements.h"
#import "CGGeometry.h"

@implementation PhotoFormElement

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (!self) return nil;

    self.imageView.image = image;

    return self;
}


- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        self.imageView = imageView;
    }
    return _imageView;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.imageView.frame = self.bounds;
}

- (CGFloat)expectedHeight {
    return 200;
}

@end

@implementation SegmentedControlFormElement

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles {
    self = [super init];
    if (!self) return nil;

    [self updateTitles:titles];

    return self;
}


- (CGFloat)expectedHeight {
    return 44;
}

- (UISegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] init];
        [self addSubview:segmentedControl];
        self.segmentedControl = segmentedControl;
    }
    return _segmentedControl;
}

- (void)updateTitles:(NSArray<NSString *> *)titles {
    for (NSString *title in titles.reverseObjectEnumerator) {
        [self.segmentedControl insertSegmentWithTitle:title atIndex:0 animated:false];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.segmentedControl.frame = CGRectInset(self.bounds, 12, 8);
}

@end

@implementation DamageButtonFormElement

- (CGFloat)expectedHeight {
    return 94;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i <= 5; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *buttonName = [NSString stringWithFormat:@"btn_damage_%d", i];
        NSString *buttonNameOn = [buttonName stringByAppendingString:@"_on"];
        [button setImage:[UIImage imageNamed:buttonName] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:buttonNameOn] forState:UIControlStateSelected];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [array addObject:button];
    }
    self.buttons = array;
    
    return self;
}

- (UILabel *)conditionLabel {
    if (!_conditionLabel) {
        UILabel *conditionLabel = [UILabel new];
        conditionLabel.textColor = [UIColor darkGrayColor];
        conditionLabel.font = [UIFont systemFontOfSize:14.0f];
        conditionLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:conditionLabel];
        self.conditionLabel = conditionLabel;
    }
    return _conditionLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect workingRect = self.bounds, labelRect = CGRectZero;

    CGRectDivide(workingRect, &labelRect, &workingRect, 40, CGRectMaxYEdge);
    labelRect = CGRectInset(labelRect, 10, 0);

    workingRect = CGRectInset(workingRect, 15, 10);

    CGFloat buttonWidth = self.buttons.firstObject.imageView.image.size.width;

    CGFloat paddingWidth = (workingRect.size.width - buttonWidth * self.buttons.count) / (self.buttons.count - 1);

    for (UIButton *button in self.buttons) {
        CGRect buttonRect = CGRectZero;
        CGRectDivide(workingRect, &buttonRect, &workingRect, buttonWidth, CGRectMinXEdge);
        button.frame = buttonRect;
        workingRect = CGRectTrim(workingRect, paddingWidth, CGRectMinXEdge);
    }

    self.conditionLabel.frame = labelRect;
}

- (void)buttonTapped:(UIButton *)sender {
    for (UIButton *button in self.buttons) {
        button.selected = NO;
    }
    sender.selected = YES;
    [self updateConditionLabel];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (int)selectedValue {
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        if (button.isSelected) {
            return i;
        }
    }
    return 0;
}

- (void)updateConditionLabel {
    NSArray<NSString *> *labels = @[
                                    @"Condition unknown.",
                                    @"No damage, good condition.",
                                    @"Minor damage, fair condition.",
                                    @"Moderate damage, poor condition.",
                                    @"Severe damage, very bad condition.",
                                    @"Collapsed, destroyed.",
                                    ];
    self.conditionLabel.text = labels[self.selectedValue];
}

- (void)setSelectedValue:(int)selectedValue {
    for (UIButton *button in self.buttons) {
        button.selected = NO;
    }
    self.buttons[selectedValue].selected = YES;

    [self updateConditionLabel];
}

@end


@implementation SwitchFormElement

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (!self) return nil;

    self.label.text = title;

    return self;
}

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [[UILabel alloc] init];
        [self addSubview:label];
        self.label = label;
    }
    return _label;
}

- (UISwitch *)toggle {
    if (!_toggle) {
        UISwitch *toggle = [[UISwitch alloc] init];
        [self addSubview:toggle];
        self.toggle = toggle;
    }
    return _toggle;
}

- (CGFloat)expectedHeight {
    return 60;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect workingRect = self.bounds;

    workingRect = CGRectInset(workingRect, 15, 14);

    CGRect labelRect = CGRectZero, toggleRect = CGRectZero;

    CGRectTrim(workingRect, 0, CGRectMaxXEdge);
    CGRectDivide(workingRect, &toggleRect, &labelRect, self.toggle.frame.size.width, CGRectMaxXEdge);
    
    self.label.frame = labelRect;
    self.toggle.frame = toggleRect;
}

@end


@implementation TextFormElement

- (instancetype)initWithPlaceholder:(NSString *)placeholder initialText:(NSString *)initialText {
    self = [super init];
    if (!self) return nil;

    self.textField.text = initialText;
    self.textField.placeholder = placeholder;

    return self;
}

- (instancetype)initWithImmutableText:(NSString *)text {
    self = [super init];
    if (!self) return nil;

    self.textField.text = text;
    self.textField.enabled = false;

    return self;
}

- (CGFloat)expectedHeight {
    return 44;
}

- (UITextField *)textField {
    if (!_textField) {
        UITextField *textField = [[UITextField alloc] init];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:textField];
        self.textField = textField;
    }
    return _textField;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect workingRect = self.bounds;
    workingRect = CGRectInset(workingRect, 15, 0);
    self.textField.frame = workingRect;
}

@end

@implementation MultiLineLabelFormElement

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (!self) return nil;

    self.label.text = text;

    return self;
}

- (CGFloat)verticalPadding {
    return 10;
}

- (CGFloat)expectedHeight {
    return [self.label sizeThatFits:self.bounds.size].height + 2*[self verticalPadding];
}

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [[UILabel alloc] init];\
        label.numberOfLines = 0;
        [self addSubview:label];
        self.label = label;
    }
    return _label;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect workingRect = self.bounds;
    workingRect = CGRectInset(workingRect, 15, [self verticalPadding]);
    self.label.frame = workingRect;
}

@end



@implementation ButtonFormElement


- (instancetype)initWithTitle:(NSString *)title {
    return [self initWithTitle:title block:^{ }];
}

- (instancetype)initWithTitle:(NSString *)title block:(void (^)())block {
    self = [super init];
    if (!self) return nil;

    [self.innerButton setTitle:title forState:UIControlStateNormal];
    self.block = block;

    return self;
}

- (CGFloat)expectedHeight {
    return 44;
}

- (UIButton *)innerButton {
    if (!_innerButton) {
        UIButton *innerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [innerButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        innerButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
        [innerButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:innerButton];
        self.innerButton = innerButton;
    }
    return _innerButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect workingRect = self.bounds;
    workingRect = CGRectInset(workingRect, 15, 0);
    self.innerButton.frame = workingRect;
}

- (void)buttonTapped:(id)sender {
    if (self.block) {
        self.block();
    }
}

@end


@implementation TextViewFormElement

- (CGFloat)expectedHeight {
    return 100;
}

- (UITextView *)textView {
    if (!_textView) {
        UITextView *textView = [[UITextView alloc] init];
        textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
        textView.font = [UIFont systemFontOfSize:18.0];
        [self addSubview:textView];
        self.textView = textView;
    }
    return _textView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect workingRect = self.bounds;
    self.textView.frame = workingRect;
}

@end



@implementation MapFormElement

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (!self) return nil;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
    [self.mapView setRegion:viewRegion animated:NO];

    return self;
}


- (CGFloat)expectedHeight {
    return 80;
}

- (MKMapView *)mapView {
    if (!_mapView) {
        MKMapView *mapView = [[MKMapView alloc] init];
        mapView.scrollEnabled = NO;
        mapView.zoomEnabled = NO;
        [self addSubview:mapView];
        self.mapView = mapView;
    }
    return _mapView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect workingRect = self.bounds;
    self.mapView.frame = workingRect;
}

@end

@interface FormGroup ()

@property (nonatomic) NSMutableArray *formElements;
@property (nonatomic) NSMutableArray *separators;
@property (nonatomic) UILabel *headerLabel;

@end

@implementation FormGroup

- (instancetype)initWithHeaderText:(NSString *)headerText formElements:(NSArray<UIView<FormElement> *> *)formElements {
    self = [super init];
    if (!self) return nil;

    [self updateHeaderText:headerText];
    for (UIView<FormElement> *element in formElements) {
        [self addFormElement:element];
    }

    return self;
}

- (NSMutableArray *)formElements {
    if (!_formElements) {
        _formElements = [@[] mutableCopy];
    }
    return _formElements;
}

- (NSMutableArray *)separators {
    if (!_separators) {
        _separators = [@[] mutableCopy];
    }
    return _separators;
}

- (UILabel *)headerLabel {
    if (!_headerLabel) {
        UILabel *headerLabel = [[UILabel alloc] init];
        headerLabel.font = [UIFont systemFontOfSize:13];
        headerLabel.textColor = [UIColor grayColor];
        [self addSubview:headerLabel];
        self.headerLabel = headerLabel;
    }
    return _headerLabel;
}

- (CGFloat)labelTopPadding {
    return 20;
}

- (CGFloat)labelHeight {
    return 25;
}

- (CGFloat)expectedHeight {
    return self.labelTopPadding + self.labelHeight + [[self.formElements valueForKeyPath:@"@sum.expectedHeight"] floatValue];
}

- (void)updateHeaderText:(NSString *)headerText {
    self.headerLabel.text = [headerText uppercaseString];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect workingRect = self.bounds;

    CGRect headerRect = CGRectZero;

    CGRectTrim(workingRect, [self labelTopPadding], CGRectMinYEdge);

    CGRectDivide(workingRect, &headerRect, &workingRect, [self labelHeight], CGRectMinYEdge);

    self.headerLabel.frame = CGRectInset(headerRect, 16, 2);

    for (int i = 0; i < self.formElements.count; i++) {
        UIView<FormElement> *element = self.formElements[i];
        UIView *separator = nil;
        if (i != 0) {
            separator = self.separators[i];
        }
        CGRect elementRect = CGRectZero;
        CGRectDivide(workingRect, &elementRect, &workingRect, element.expectedHeight, CGRectMinYEdge);
        element.backgroundColor = [UIColor whiteColor];
        element.frame = elementRect;
        CGRect separatorRect = elementRect;
        separatorRect.size.height = 1/UIScreen.mainScreen.scale;
        separatorRect = CGRectTrim(separatorRect, 10, CGRectMinXEdge);
        separator.frame = separatorRect;
    }
}

- (void)addFormElement:(UIView<FormElement> *)formElement {
    [self.formElements addObject:formElement];
    [self addSubview:formElement];
    UIView *separator = [[UIView alloc] init];
    separator.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:separator];
    [self.separators addObject:separator];
}

@end

