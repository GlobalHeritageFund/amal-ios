//
//  Firebase+Promises.h
//  Amal
//
//  Created by Soroush Khanlou on 7/7/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

@import Firebase;
@import FirebaseDatabase;
@import FirebaseUI;

@interface FIRDatabaseReference (Promises)

- (Promise<FIRDatabaseReference*> *_Nonnull)promiseSetValue:(nullable id)value;

- (Promise<FIRDatabaseReference *> *_Nonnull)promiseGet;

@end

@interface FIRStorageReference (Promises)

- (Promise<NSData *> *_Nonnull)dataWithMaxSize:(int64_t)size;

@end

@interface FIRStorageObservableTask (Promises)

- (Promise<FIRStorageMetadata *> *_Nonnull)promise;

@end

@interface FUIAuth (Promises)

- (Promise *)signInPromise;

@end
