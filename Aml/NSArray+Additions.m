//
//  NSArray+Additions.m
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

- (NSArray *)arrayBySelectingObjectsPassingTest:(BOOL (^)(id object))test {
    NSParameterAssert(test != nil);

    NSIndexSet *indexesOfSelectedObjects = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return test(obj);
    }];
    return [self objectsAtIndexes:indexesOfSelectedObjects];
}

- (NSArray *)arrayByRejectingObjectsPassingTest:(BOOL (^)(id))test {
    return [self arrayBySelectingObjectsPassingTest:^BOOL(id object) {
        return !test(object);
    }];
}

- (NSArray *)arrayByTransformingObjectsUsingBlock:(id (^)(id object))block {
    NSParameterAssert(block != nil);

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj);
        if (!value) value = [NSNull null];
        [result addObject:value];
    }];

    return result;
}

@end
