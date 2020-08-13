//
//  NSJSONSerialization+Promises.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/20/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"

@interface NSJSONSerialization (Promises)

+ (Promise <NSDictionary *> *)JSONDictionaryFromData:(NSData *)data;

@end
