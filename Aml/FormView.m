//
//  FormView.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "FormView.h"
#import "UIColor+Additions.h"
#import "NotesForm.h"

@interface FormView ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSMutableArray *formGroups;

@end

@implementation FormView

- (NSMutableArray *)formGroups {
    if (!_formGroups) {
        _formGroups = [@[] mutableCopy];
    }
    return _formGroups;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.alwaysBounceVertical = true;
        scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        scrollView.backgroundColor = [UIColor colorWithHex:0xEFEFF4];
        [self addSubview:scrollView];
        self.scrollView = scrollView;
    }
    return _scrollView;
}

- (void)addFormGroup:(FormGroup *)formGroup {
    [self.scrollView addSubview:formGroup];
    [self.formGroups addObject:formGroup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, [[self.formGroups valueForKeyPath:@"@sum.expectedHeight"] floatValue]);
    CGRect workingRect = self.bounds;
    workingRect.size.height = self.scrollView.contentSize.height;
    for (FormGroup *group in self.formGroups) {
        CGRect groupRect = CGRectZero;
        CGRectDivide(workingRect, &groupRect, &workingRect, group.expectedHeight, CGRectMinYEdge);
        group.frame = groupRect;
    }
}

@end
