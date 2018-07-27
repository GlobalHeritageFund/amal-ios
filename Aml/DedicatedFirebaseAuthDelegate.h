//
//  DedicatedFirebaseAuthDelegate.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 7/26/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseUI/FirebaseAuthUI.h>
#import "Promise.h"

@interface DedicatedFirebaseAuthDelegate : NSObject <FUIAuthDelegate>

@property (nonatomic, copy) void (^success)(FIRAuthDataResult *result);
@property (nonatomic, copy) void (^error)(NSError *error);

@end
