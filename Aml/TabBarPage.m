//
//  TabBarPage.m
//  Amal
//
//  Created by Dustin Dettmer on 3/13/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "TabBarPage.h"

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
    
    for (UITabBarItem *tbi in self.tabBar.items) {
        
        tbi.selectedImage = [tbi.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

@end
