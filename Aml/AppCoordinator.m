//
//  AppCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "AppCoordinator.h"

@implementation FirstLaunch

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (NSString *)firstLaunchKey {
    return @"AMALFirstLaunch";
}

- (BOOL)isFirstLaunch {
    return [self.userDefaults boolForKey:self.firstLaunchKey];
}

- (void)launched {
    [self.userDefaults setBool:YES forKey:self.firstLaunchKey];
}

@end

@interface AppCoordinator ()

@property (nonatomic) FirstLaunch *firstLaunch;


@end

@implementation AppCoordinator

- (instancetype)initWithWindow:(UIWindow *)window {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.window = window;
    return self;
}

- (FirstLaunch *)firstLaunch {
    if (!_firstLaunch) {
        _firstLaunch = [FirstLaunch new];
    }
    return _firstLaunch;
}

- (void)start {
    UIViewController *tabBarController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];

    if (self.firstLaunch.isFirstLaunch) {
        UIViewController *page = [[UIStoryboard storyboardWithName:@"Intro" bundle:nil] instantiateInitialViewController];

        [self.window.rootViewController presentViewController:page animated:YES completion:nil];

        [self.firstLaunch launched];
    }

}

@end
