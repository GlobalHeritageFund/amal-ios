//
//  Firebase+Promises.m
//  Amal
//
//  Created by Soroush Khanlou on 7/7/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

@import FirebaseDatabase;
@import FirebaseStorage;
@import FirebaseUI;
#import "Promise.h"
#import "DedicatedFirebaseAuthDelegate.h"

@implementation FIRDatabaseReference (Promises)

- (Promise *)promiseSetValue:(id)value {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        [self setValue:value withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                reject(error);
            } else if (ref) {
                fulfill(ref);
            }
        }];
    }];
}

- (Promise<NSDictionary *> *)promiseGet {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(NSDictionary *_Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        [self observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if ([snapshot.value isKindOfClass:[NSNull class]]) {
                return; //should reject instead
            }
            fulfill(snapshot.value);
        }];
    }];
}

@end

@implementation FIRStorageReference (Promises)

- (Promise<NSData *> *)dataWithMaxSize:(int64_t)size {
    return [[Promise alloc] initWithWorkQueue:dispatch_get_main_queue() work:^(void (^ _Nonnull fulfill)(NSData *_Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        [self dataWithMaxSize:INT64_MAX completion:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (error) {
                reject(error);
            } else {
                fulfill(data);
            }
        }];
    }];
}

@end

@implementation FIRStorageObservableTask (Promises)

- (Promise<FIRStorageMetadata *> *)promise {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        [self observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
            fulfill(snapshot.metadata);
        }];
        [self observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
            reject(snapshot.error);
        }];
    }];
}

@end

@implementation FIRAuth (Promises)

- (Promise *)anonymousSignInPromise {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        [self signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
            if (authResult) {
                fulfill(authResult);
            }
            else {
                reject(error);
            }
        }];
    }];
}

@end

@implementation FUIAuth (Promises)

- (Promise *)signInPromise {
    DedicatedFirebaseAuthDelegate *delegate = [[DedicatedFirebaseAuthDelegate alloc] init];
    self.delegate = delegate;
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        delegate.success = ^(FIRAuthDataResult *result) {
            fulfill(result);
        };
        delegate.error = ^(NSError *error) {
            reject(error);
        };
    }];
}

@end

