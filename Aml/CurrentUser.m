//
//  CurrentUser.m
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "CurrentUser.h"

@implementation CurrentUser

+ (instancetype)shared {
    static CurrentUser *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        instance = [self new];
    });

    return instance;
}

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (NSString *)deviceTokenKey {
    return @"AMALDeviceToken";
}

- (NSString *)deviceToken {
    NSString *deviceToken = [self.userDefaults stringForKey:self.deviceTokenKey];
    if (deviceToken == nil) {
        deviceToken = [[NSUUID UUID] UUIDString];
        self.deviceToken = deviceToken;
    }

    return deviceToken;
}

- (void)setDeviceToken:(NSString *)deviceToken {
    [self.userDefaults setObject:deviceToken forKey:self.deviceTokenKey];
}


@end
