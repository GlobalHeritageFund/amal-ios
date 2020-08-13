//
//  AssessViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormView.h"

@class LocalPhoto, MultiAssessViewController;

@protocol MultiAssessViewControllerDelegate

- (void)multiAssessViewControllerDidTapEditCoordinates:(MultiAssessViewController *)assessViewController;

@end

@interface MultiAssessViewController : UIViewController

@property (nonatomic) FormView *view;

@property (weak) id<MultiAssessViewControllerDelegate> delegate;

@property (readonly) NSArray<LocalPhoto *> *photos;

- (instancetype)initWithPhotos:(NSArray<LocalPhoto *> *)localPhoto;

@end

