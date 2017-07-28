//
//  Firebase+Promises.h
//  Amal
//
//  Created by Soroush Khanlou on 7/7/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "Firebase.h"
#import "Promise.h"

@interface FIRDatabaseReference (Promises)

- (Promise<FIRDatabaseReference*> *_Nonnull)promiseSetValue:(nullable id)value;

@end


@interface FIRStorageObservableTask (Promises)

- (Promise<FIRStorageMetadata *> *_Nonnull)promise;

@end
