//
//  CaptureNotesView.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FormGroup;

@interface CaptureNotesView : UIView

@property (readonly) UIScrollView *scrollView;

- (void)addFormGroup:(FormGroup *)formGroup;

@end
