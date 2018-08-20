//
//  NSJSONSerialization+Promises.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/20/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "NSJSONSerialization+Promises.h"

@implementation NSJSONSerialization (Promises)

+ (Promise <NSDictionary *> *)JSONDictionaryFromData:(NSData *)data {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(NSDictionary * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        NSError *error = nil;
        NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!JSONDictionary) {
            reject(error);
        }
        else {
            fulfill(JSONDictionary);
        }
    }];
}

@end
