//
//  AssessViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormView.h"

@class LocalPhoto, AssessViewController;

@protocol AssessViewControllerDelegate

- (void)assessViewControllerDidTapEditCoordinates:(AssessViewController *)assessViewController;

@end

@interface AssessViewController : UIViewController

@property (nonatomic) FormView *view;

@property (weak) id<AssessViewControllerDelegate> delegate;

@property (nonatomic, readonly) LocalPhoto *photo;

- (instancetype)initWithPhoto:(LocalPhoto *)localPhoto;

@end

