//
//  NSURLSession+Promises.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSURLSession+Promises.h"
#import "MultipartComponent.h"
#import "MultipartFormData.h"
#import "NSJSONSerialization+Promises.h"

@implementation NSURLSession (Promises)

- (Promise <NSData *> *)taskWithRequest:(NSURLRequest *)request {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(NSData * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        
        NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSHTTPURLResponse *URLResponse = (NSHTTPURLResponse *)response;
            if (data && (URLResponse.statusCode == 200 || URLResponse.statusCode == 201)) {
                fulfill(data);
            }
            else {
                reject(error);
            }
        }];
        
        [task resume];
    }];
}

- (Promise *)JSONtaskWithRequest:(NSURLRequest *)request {
    return [[self taskWithRequest:request] then:^id _Nullable(NSData * _Nonnull object) {
        return [NSJSONSerialization JSONDictionaryFromData:object];
    }];
}

@end
