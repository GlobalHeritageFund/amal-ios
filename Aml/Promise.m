//
//  Promise.m
//  Promise
//
//  Created by Soroush Khanlou on 7/7/17.
//  Copyright © 2017 Soroush Khanlou. All rights reserved.
//

#import "Promise.h"

@implementation Unit

@end

@interface Callback : NSObject

@property (nonatomic, copy, nullable) SuccessBlock onSuccess;
@property (nonatomic, copy, nullable) FailureBlock onFailure;

@end

@implementation Callback

- (void)call:(id)object {
    if (object == nil) {
        return;
    }
    if ([object isKindOfClass:[NSError class]]) {
        if (self.onFailure) {
            self.onFailure(object);
        }
        return;
    }
    if (self.onSuccess) {
        self.onSuccess(object);
    }
}

@end


@interface Promise ()

@property (nonatomic) id valueOrError;
@property (nonatomic) NSMutableArray<Callback *> *callbacks;

@end

@implementation Promise

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    self.callbacks = [NSMutableArray array];
    self.valueOrError = nil;

    return self;
}


- (instancetype _Nonnull )initWithWork:(void (^)(void (^fulfill)(id), void (^reject)(NSError *)))resolver {

    self = [self init];
    if (!self) return nil;

    resolver(
             ^(id obj) {
                 [self fulfill:obj];
             },
             ^(NSError *error) {
                 [self reject:error];
             });


    return self;
}

- (void)fulfill:(id)value {
    self.valueOrError = value;
}

- (void)reject:(NSError *)error {
    self.valueOrError = error;
}

- (void)setValueOrError:(id)valueOrError {
    if (self.valueOrError != nil) { return; }
    _valueOrError = valueOrError;
    [self callCallbacks];
}

- (void)callCallbacks {
    for (Callback *callback in self.callbacks) {
        [callback call:self.valueOrError];
    }
}

- (void)addCallbackWithSuccess:(SuccessBlock __nullable)onSuccess failure:(FailureBlock __nullable)onFailure {
    Callback *callback = [Callback new];
    callback.onSuccess = onSuccess;
    callback.onFailure = onFailure;
    [self.callbacks addObject:callback];
}

- (BOOL)isPending {
    return self.valueOrError == nil;
}

- (BOOL)isRejected {
    return [self.valueOrError isKindOfClass:[NSError class]];
}

- (BOOL)isFulfilled {
    return !self.isPending && !self.isRejected;
}

- (id)value {
    if (self.isFulfilled) {
        return self.valueOrError;
    }
    return nil;
}

- (NSError *)error {
    if (self.isRejected) {
        return self.valueOrError;
    }
    return nil;
}

- (Promise * _Nonnull)then:(id (^_Nonnull)(id _Nonnull object))onSuccess {
    Promise *promise = [[Promise alloc] init];
    [self addCallbackWithSuccess:^(id  _Nonnull object) {
        id value = onSuccess(object);
        if (value == nil) {
            [promise fulfill:object];
        } else if ([value isKindOfClass:[Promise class]]) {
            Promise *p = value;
            [[p then:^id _Nullable(id  _Nonnull object) {
                [promise fulfill:object];
                return nil;
            }] catch:^(NSError * _Nonnull error) {
                [promise reject:error];
            }];
        } else {
            [promise fulfill:value];
        }
    } failure:^(NSError * _Nonnull error) {
        [promise reject:error];
    }];
    return promise;
}

- (Promise * _Nonnull)catch:(void (^_Nonnull)(NSError * _Nonnull error))onFailure {
    Promise *promise = [[Promise alloc] init];
    [self addCallbackWithSuccess:^(id  _Nonnull object) {
        [promise fulfill:object];
    } failure:^(NSError * _Nonnull error) {
        onFailure(error);
        [promise reject:error];
    }];
    return promise;
}

+ (Promise *)delay:(NSTimeInterval)interval {
    Promise *delay = [[Promise alloc] init];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, interval*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [delay fulfill:[Unit new]];
    });
    
    return delay;
}

+ (Promise *)fulfilled:(id)value {
    Promise *fulfilled = [[Promise alloc] init];
    [fulfilled fulfill:value];
    return fulfilled;
}

+ (Promise *)rejected:(NSError *)error {
    Promise *rejected = [[Promise alloc] init];
    [rejected reject:error];
    return rejected;
}

+ (Promise *)all:(NSArray<Promise *> *)promises {
    Promise *all = [[Promise alloc] init];

    dispatch_group_t group = dispatch_group_create();

    for (Promise *promise in promises) {
        dispatch_group_enter(group);
        [[promise then:^id _Nullable(id  _Nonnull object) {
            dispatch_group_leave(group);
            return nil;
        }] catch:^(NSError * _Nonnull error) {
            [all reject:error];
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [all fulfill:[promises valueForKey:@"value"]];
    });

    return all;
}

@end
