//
//  Promise.h
//  Promise
//
//  Created by Soroush Khanlou on 7/7/17.
//  Copyright © 2017 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Unit : NSObject

@end

typedef void (^SuccessBlock)(id _Nonnull object);
typedef id _Nullable (^ _Nonnull ThenBlock)(id _Nonnull object);
typedef void (^FailureBlock)(NSError * _Nonnull error);

@interface Promise<T> : NSObject

- (instancetype _Nonnull )initWithWork:(void (^ __nonnull)(void (^ __nonnull fulfill)(__nonnull T), void (^ __nonnull reject)(NSError * __nonnull)))resolver;

-(void)fulfill:(nonnull T)value;
-(void)reject:(nonnull NSError *)error;

- (Promise<T> * _Nonnull)then:(ThenBlock _Nonnull)onSuccess;
- (Promise<T> * _Nonnull)catch:(FailureBlock _Nonnull)onFailure;

- (BOOL)isPending;
- (BOOL)isRejected;
- (BOOL)isFulfilled;

- (T _Nullable )value;
- (NSError *_Nullable)error;

+ (Promise<Unit *> *_Nonnull)delay:(NSTimeInterval)interval;

+ (Promise *_Nonnull)fulfilled:(id _Nonnull )value;
+ (Promise *_Nonnull)rejected:(NSError *_Nonnull)error;

+ (Promise *_Nonnull)all:(NSArray<Promise *> *_Nonnull)promises;

@end
