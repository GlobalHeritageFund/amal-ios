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

@implementation FIRStorageReference (Promises)

- (Promise *)promisePutData:(NSData *)data metadata:(FIRStorageMetadata *)metadata {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        [self putData:data metadata:metadata completion:^(FIRStorageMetadata * _Nullable metadata, NSError * _Nullable error) {
            if (error) {
                reject(error);
            } else if (metadata) {
                fulfill(metadata);
            }
        }];
    }];
}

@end
