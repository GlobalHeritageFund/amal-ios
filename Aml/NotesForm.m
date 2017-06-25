//
//  sd.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "NotesForm.h"
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
    return 64;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    NSMutableArray *array = [NSMutableArray array];
    for (int i = 1; i <= 5; i++) {
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

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect workingRect = self.bounds;

    workingRect = CGRectInset(workingRect, 15, 15);

    CGFloat buttonWidth = self.buttons.firstObject.imageView.image.size.width;

    CGFloat paddingWidth = (workingRect.size.width - buttonWidth * self.buttons.count) / (self.buttons.count - 1);

    for (UIButton *button in self.buttons) {
        CGRect buttonRect = CGRectZero;
        CGRectDivide(workingRect, &buttonRect, &workingRect, buttonWidth, CGRectMinXEdge);
        button.frame = buttonRect;
        workingRect = CGRectTrim(workingRect, paddingWidth, CGRectMinXEdge);
    }
}

- (void)buttonTapped:(UIButton *)sender {
    for (UIButton *button in self.buttons) {
        button.selected = NO;
    }
    sender.selected = YES;
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


@implementation NotesFormElement

- (CGFloat)expectedHeight {
    return 44;
}

- (UITextField *)textField {
    if (!_textField) {
        UITextField *textField = [[UITextField alloc] init];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.placeholder = @"Notes";
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


@interface FormGroup ()

@property (nonatomic) NSMutableArray *formElements;
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

    for (UIView<FormElement> *element in self.formElements) {
        CGRect elementRect = CGRectZero;
        CGRectDivide(workingRect, &elementRect, &workingRect, element.expectedHeight, CGRectMinYEdge);
        element.backgroundColor = [UIColor whiteColor];
        element.frame = elementRect;
    }
}

-(void)addFormElement:(UIView<FormElement> *)formElement {
    [self.formElements addObject:formElement];
    [self addSubview:formElement];
}

@end

