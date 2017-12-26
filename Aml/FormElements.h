//
//  FormElements.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

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

@property (nonatomic) UILabel *conditionLabel;

@end


@interface SwitchFormElement : UIView <FormElement>

- (instancetype)initWithTitle:(NSString *)title;

@property (nonatomic) UILabel *label;
@property (nonatomic) UISwitch *toggle;

@end


@interface TextFormElement : UIView <FormElement>

- (instancetype)initWithPlaceholder:(NSString *)placeholder initialText:(NSString *)initialText;

- (instancetype)initWithImmutableText:(NSString *)text;

@property (nonatomic) UITextField *textField;

@end


@interface TextViewFormElement : UIView <FormElement>

@property (nonatomic) UITextView *textView;

@end


@interface ButtonFormElement : UIView <FormElement>

@property (nonatomic) UIButton *innerButton;

- (instancetype)initWithTitle:(NSString *)title;

@end


@interface MapFormElement : UIView <FormElement>

@property (nonatomic) MKMapView *mapView;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end


@interface FormGroup : UIView

- (instancetype)initWithHeaderText:(NSString *)headerText formElements:(NSArray<UIView<FormElement> *> *)formElements;

- (void)addFormElement:(UIView<FormElement> *)formElement;

- (void)updateHeaderText:(NSString *)headerText;

- (CGFloat)expectedHeight;

@end

