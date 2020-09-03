//
//  SettingsViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 12/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormView.h"

@protocol SettingsViewControllerDelegate

- (void)didSelectEnterPassphrase;
- (void)didSelectAcknowledgements;

@end

@interface SettingsViewController : UIViewController

- (instancetype)initWithDelegate:(id <SettingsViewControllerDelegate>)delegate;

@property (nonatomic) FormView *view;

@end
