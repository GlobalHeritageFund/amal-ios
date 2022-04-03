//
//  PassphraseValidator.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/7/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"

typedef NS_ENUM(NSInteger, PassphraseUnlockStatus) {
    PassphraseUnlockStatusEAMENA,
    PassphraseUnlockStatusLebanon,
    PassphraseUnlockStatusUkraine
};

@interface PassphraseValidator : NSObject

- (Promise<NSNumber *>*)unlockStatusForPassphraseAttempt:(NSString *)passphraseAttempt;

@end
