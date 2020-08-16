//
//  CurrentUser.m
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "CurrentUser.h"
@import FirebaseAuth;

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

- (NSString *)EAMENAEnabledKey {
    return @"EAMENAEnabledKey";
}

- (NSString *)lebanonEAMENAEnabledKey {
    return @"LebanonEAMENAEnabledKey";
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

- (NSString *)emailAddress {
    return [FIRAuth auth].currentUser.email;
}

- (BOOL)isEAMENAUnlocked {
    return [self.userDefaults boolForKey:self.EAMENAEnabledKey];
}

- (void)setIsEAMENAUnlocked:(BOOL)isEAMENAUnlocked {
    [self.userDefaults setBool:isEAMENAUnlocked forKey:self.EAMENAEnabledKey];
}

- (BOOL)isLebanonUnlocked {
    return [self.userDefaults boolForKey:self.lebanonEAMENAEnabledKey];
}

- (void)setIsLebanonUnlocked:(BOOL)isLebanonUnlocked {
    [self.userDefaults setBool:isLebanonUnlocked forKey:self.lebanonEAMENAEnabledKey];
}

- (void)signOut {
    [[FIRAuth auth] signOut:nil];
}

- (BOOL)isLoggedIn {
    return [FIRAuth auth].currentUser != nil;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
             @"email" : self.emailAddress ?: [NSNull null],
             @"deviceToken" : self.deviceToken
             };
}

@end
