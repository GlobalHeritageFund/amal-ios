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
@property (nonatomic, strong, nonnull) dispatch_queue_t queue;

@end

@implementation Callback

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    _queue = dispatch_get_main_queue();

    return self;
}


- (void)call:(id)object {
    if (object == nil) {
        return;
    }
    if ([object isKindOfClass:[NSError class]]) {
        if (self.onFailure) {
            dispatch_async(self.queue, ^{
                self.onFailure(object);
            });
        }
        return;
    }
    if (self.onSuccess) {
        dispatch_async(self.queue, ^{
            self.onSuccess(object);
        });
    }
}

@end


@interface Promise ()

@property (nonatomic) id valueOrError;
@property (nonatomic) NSMutableArray<Callback *> *callbacks;
@property (nonatomic) dispatch_queue_t queue;


@end

@implementation Promise

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    self.callbacks = [NSMutableArray array];
    self.valueOrError = nil;
    self.queue = dispatch_queue_create("promise.queue", DISPATCH_QUEUE_SERIAL);

    return self;
}

- (instancetype _Nonnull )initWithWork:(void (^)(void (^fulfill)(id), void (^reject)(NSError *)))work {
    return [self initWithWorkQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) work:work];
}

- (instancetype _Nonnull )initWithWorkQueue:(dispatch_queue_t)queue work:(void (^)(void (^fulfill)(id), void (^reject)(NSError *)))work {
    self = [self init];
    if (!self) return nil;

    dispatch_async(queue, ^{
        work(
                 ^(id obj) {
                     [self fulfill:obj];
                 },
                 ^(NSError *error) {
                     [self reject:error];
                 });
    });

    return self;
}

- (void)fulfill:(id)value {
    [self updateWithValue:value];
}

- (void)reject:(NSError *)error {
    [self updateWithValue:error];
}

- (void)updateWithValue:(id)valueOrError {
    dispatch_async(self.queue, ^{
        if (self.valueOrError != nil) { return; }
        self.valueOrError = valueOrError;
        [self callCallbacks];
    });
}

- (void)callCallbacks {
    dispatch_async(self.queue, ^{
        BOOL isPending = (self.valueOrError == nil);
        if (isPending) { return; }
        for (Callback *callback in self.callbacks) {
            [callback call:self.valueOrError];
        }
        [self.callbacks removeAllObjects];
    });
}

- (void)addCallbackWithSuccess:(SuccessBlock __nullable)onSuccess failure:(FailureBlock __nullable)onFailure queue:(dispatch_queue_t)queue {
    Callback *callback = [Callback new];
    callback.onSuccess = onSuccess;
    callback.onFailure = onFailure;
    callback.queue = queue;
    dispatch_async(self.queue, ^{
        [self.callbacks addObject:callback];
    });
}

- (void)addCallbackWithSuccess:(SuccessBlock __nullable)onSuccess failure:(FailureBlock __nullable)onFailure {
    return [self addCallbackWithSuccess:onSuccess failure:onFailure queue:dispatch_get_main_queue()];
}

- (BOOL)isPending {
    __block BOOL isPending = NO;
    dispatch_sync(self.queue, ^{
        isPending = (self.valueOrError == nil);
    });
    return isPending;
}

- (BOOL)isRejected {
    __block BOOL isRejected = NO;
    dispatch_sync(self.queue, ^{
        isRejected = [self.valueOrError isKindOfClass:[NSError class]];
    });
    return isRejected;
}

- (BOOL)isFulfilled {
    return !self.isPending && !self.isRejected;
}

- (id)value {
    __block id value = nil;
    dispatch_sync(self.queue, ^{
        if (self.valueOrError != nil && ![self.valueOrError isKindOfClass:[NSError class]]) {
            value = self.valueOrError;
        }
    });
    return value;
}

- (NSError *)error {
    __block id error = nil;
    dispatch_sync(self.queue, ^{
        if ([self.valueOrError isKindOfClass:[NSError class]]) {
            error = self.valueOrError;
        }
    });
    return error;
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
            dispatch_group_leave(group);
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [all fulfill:[promises valueForKey:@"value"]];
    });

    return all;
}

@end
