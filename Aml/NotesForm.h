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

@property (nonatomic) UIImageView *imageView;


@end

@interface SegmentedControlFormElement : UIView <FormElement>

@property (nonatomic) UISegmentedControl *segmentedControl;


@end

@interface MultiButtonFormElement : UIView <FormElement>

@property (nonatomic) UIStackView *stackView;

@end

@interface SwitchFormElement : UIView <FormElement>

@property (nonatomic) UILabel *label;
@property (nonatomic) UISwitch *toggle;

@end

@interface NotesFormElement : UIView <FormElement>

@property (nonatomic) UILabel *label;
@property (nonatomic) UITextField *textField;

@end

@interface FormGroup : UIView

- (void)addFormElement:(UIView<FormElement> *)formElement;

- (void)updateHeaderText:(NSString *)headerText;

- (CGFloat)expectedHeight;

@end

