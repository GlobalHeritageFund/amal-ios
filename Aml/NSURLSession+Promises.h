//
//  NSURLSession+Promises.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"

@interface NSURLSession (Promises)

- (Promise <NSData *> *)taskWithRequest:(NSURLRequest *)request;
- (Promise <NSDictionary *> *)JSONtaskWithRequest:(NSURLRequest *)request;

@end
