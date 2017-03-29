//
//  UIViewController+Additions.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

- (IBAction)popNavigationController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
