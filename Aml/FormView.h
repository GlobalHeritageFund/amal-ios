//
//  FormView.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FormGroup;

@interface FormView : UIView

@property (readonly) UIScrollView *scrollView;

- (void)addFormGroup:(FormGroup *)formGroup;

@end

