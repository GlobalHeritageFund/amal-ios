//
//  AppCoordinator.h
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstLaunch : NSObject

- (BOOL)isFirstLaunch;

- (void)launched;

@end

@interface AppCoordinator : NSObject

@property (nonatomic) UIWindow *window;

- (instancetype)initWithWindow:(UIWindow *)window;

- (void)start;

@end
