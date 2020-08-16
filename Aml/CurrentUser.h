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

@property (nonatomic) BOOL isEAMENAEnabled;

@property (nonatomic) BOOL isLebanonEnabled;

- (void)signOut;

- (NSDictionary *)dictionaryRepresentation;

@end
