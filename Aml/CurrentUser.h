//
//  CurrentUser.h
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentUser : NSObject

+ (instancetype)shared;

@property (nonatomic) NSString *deviceToken;

@property (nonatomic, readonly) NSString *emailAddress;

@property (nonatomic, readonly) BOOL isLoggedIn;

@property (nonatomic, readonly) NSArray *unlockedDatabaseTargets;

@property (nonatomic) BOOL isEAMENAUnlocked;

@property (nonatomic) BOOL isLebanonUnlocked;

@property (nonatomic) BOOL isUkraineUnlocked;

- (void)signOut;

- (NSDictionary *)dictionaryRepresentation;

@end
