//
//  NSObject+Helpers
//  Amal
//
//  Created by Soroush Khanlou on 6/29/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "NSObject+Helpers.h"

@implementation NSObject (Helpers)

- (id)asClassOrNil:(Class)cl {
    if ([self isKindOfClass:cl]) {
        return self;
    }
    return nil;
}

@end

