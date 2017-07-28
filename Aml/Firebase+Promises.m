//
//  Firebase+Promises.m
//  Amal
//
//  Created by Soroush Khanlou on 7/7/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "Firebase+Promises.h"

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
