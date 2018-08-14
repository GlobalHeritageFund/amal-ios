//
//  PassphraseUnlockDeterminer.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/7/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "PassphraseValidator.h"

@implementation PassphraseValidator

- (Promise *)unlockStatusForPassphaseAttempt:(NSString *)passphraseAttempt {
    
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(NSNumber * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        
        if ([[passphraseAttempt lowercaseString] isEqualToString:@"eamena"]) {
            fulfill(@(PassphraseUnlockStatusEAMENA));
        }
        
        reject([NSError errorWithDomain:@"com.amal.passwordvalidation" code:1 userInfo:nil]);
    }];

}

@end
