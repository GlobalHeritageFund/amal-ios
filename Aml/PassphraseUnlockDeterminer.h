//
//  PassphraseDeterminer.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/7/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PassphraseUnlockStatus) {
    PassphraseUnlockStatusNothingUnlocked,
    PassphraseUnlockStatusUnlockedEAMENA
};

@interface PassphraseUnlockDeterminer : NSObject

- (PassphraseUnlockStatus)unlockStatusForPassphaseAttempt:(NSString *)passphraseAttempt;

@end
