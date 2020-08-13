//
//  DedicatedFirebaseAuthDelegate.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 7/26/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "DedicatedFirebaseAuthDelegate.h"

@interface DedicatedFirebaseAuthDelegate ()

@property (nonatomic) id cycle;

@end

@implementation DedicatedFirebaseAuthDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        _cycle = self;
    }
    return self;
}

- (void)authUI:(FUIAuth *)authUI didSignInWithAuthDataResult:(FIRAuthDataResult *)authDataResult error:(NSError *)error {
    
    if (authDataResult) {
        self.success(authDataResult);
    } else {
        self.error(error);
    }
    
    // We need to nil this out to prevent a permanent retain cycle.
    // We have to do this in order to keep the delegate around until we are done with the cycle - this makes it possible to wrap this operation in a promise.
    self.cycle = nil;
}

@end
