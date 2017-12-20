//
//  FirstLaunch.m
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "FirstLaunch.h"

@implementation FirstLaunch

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (NSString *)firstLaunchKey {
    return @"AMALFirstLaunch";
}

- (BOOL)isFirstLaunch {
    return ![self.userDefaults boolForKey:self.firstLaunchKey];
}

- (void)launched {
    [self.userDefaults setBool:YES forKey:self.firstLaunchKey];
}

@end
