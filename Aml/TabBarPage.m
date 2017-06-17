//
//  TabBarPage.m
//  Amal
//
//  Created by Dustin Dettmer on 3/13/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "TabBarPage.h"
#import "UIColor+Additions.h"

@interface TabBarPage ()

@end

@implementation TabBarPage

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tabBar.tintColor = [UIColor amalTeal];
    
    for (UITabBarItem *tbi in self.tabBar.items) {
        tbi.imageInsets = UIEdgeInsetsZero;
        tbi.selectedImage = [tbi.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

@end
