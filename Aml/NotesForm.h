//
//  sd.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FormElement

- (CGFloat)expectedHeight;

@end


@interface PhotoFormElement : UIView <FormElement>

- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic) UIImageView *imageView;

@end


@interface SegmentedControlFormElement : UIView <FormElement>

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles;

@property (nonatomic) UISegmentedControl *segmentedControl;

@end


@interface DamageButtonFormElement : UIControl <FormElement>

@property (nonatomic) NSArray<UIButton *> *buttons;

@property (nonatomic) int selectedValue;

@end


@interface SwitchFormElement : UIView <FormElement>

- (instancetype)initWithTitle:(NSString *)title;

@property (nonatomic) UILabel *label;
@property (nonatomic) UISwitch *toggle;

@end


@interface NotesFormElement : UIView <FormElement>

@property (nonatomic) UITextField *textField;

- (instancetype)initWithText:(NSString *)text;

@end


@interface FormGroup : UIView

- (instancetype)initWithHeaderText:(NSString *)headerText formElements:(NSArray<UIView<FormElement> *> *)formElements;

- (void)addFormElement:(UIView<FormElement> *)formElement;

- (void)updateHeaderText:(NSString *)headerText;

- (CGFloat)expectedHeight;

@end

