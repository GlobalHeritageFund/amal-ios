//
//  PassphraseUnlockDeterminer.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/7/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "PassphraseUnlockDeterminer.h"

@implementation PassphraseUnlockDeterminer

- (PassphraseUnlockStatus)unlockStatusForPassphaseAttempt:(NSString *)passphraseAttempt {
    
    if ([passphraseAttempt isEqualToString:@"EAMENA"]) {
        return PassphraseUnlockStatusUnlockedEAMENA;
    }
    
    return PassphraseUnlockStatusNothingUnlocked;
}

@end
