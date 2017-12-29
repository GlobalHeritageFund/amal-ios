//
//  NSArray+Additions.h
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)

- (NSArray *)arrayBySelectingObjectsPassingTest:(BOOL (^)(id object))test;

- (NSArray *)arrayByRejectingObjectsPassingTest:(BOOL (^)(id))test;

- (NSArray *)arrayByTransformingObjectsUsingBlock:(id (^)(id object))block;

- (BOOL)allObjectsPassTest:(BOOL (^)(id object))test;

- (BOOL)anyObjectsPassTest:(BOOL (^)(id object))test;

- (BOOL)allObjectsEqual;

@end
