//
//  sd.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "NotesForm.h"

@implementation PhotoFormElement

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

- (CGFloat)expectedHeight {
    return 44;
}

@end


@implementation MultiButtonFormElement

- (CGFloat)expectedHeight {
    return 44;
}

@end


@implementation SwitchFormElement

- (CGFloat)expectedHeight {
    return 44;
}

@end


@implementation NotesFormElement

- (CGFloat)expectedHeight {
    return 44;
}

@end


@interface FormGroup ()

@property (nonatomic) NSMutableArray *formElements;
@property (nonatomic) UILabel *headerLabel;

@end

@implementation FormGroup

- (NSMutableArray *)formElements {
    if (!_formElements) {
        _formElements = [@[] mutableCopy];
    }
    return _formElements;
}

- (UILabel *)headerLabel {
    if (!_headerLabel) {
        UILabel *headerLabel = [[UILabel alloc] init];
        [self addSubview:headerLabel];
        self.headerLabel = headerLabel;
    }
    return _headerLabel;
}

- (CGFloat)expectedHeight {
    return 25 + [[self.formElements valueForKeyPath:@"@max.expectedHeight"] floatValue];
}

- (void)updateHeaderText:(NSString *)headerText {
    self.headerLabel.text = [headerText uppercaseString];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect workingRect = self.bounds;

    CGRect headerRect = CGRectZero;

    CGRectDivide(workingRect, &headerRect, &workingRect, 25, CGRectMinYEdge);

    self.headerLabel.frame = CGRectInset(headerRect, 10, 2);

    for (UIView<FormElement> *element in self.formElements) {
        CGRect elementRect = CGRectZero;
        CGRectDivide(workingRect, &elementRect, &workingRect, element.expectedHeight, CGRectMinYEdge);
        element.frame = elementRect;
    }
}

-(void)addFormElement:(UIView<FormElement> *)formElement {
    [self.formElements addObject:formElement];
    [self addSubview:formElement];
}

@end

