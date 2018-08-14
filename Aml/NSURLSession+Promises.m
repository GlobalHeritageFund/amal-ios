//
//  NSURLSession+Promises.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "NSURLSession+Promises.h"

@implementation NSURLSession (Promises)

- (Promise <NSDictionary *> *)POSTJSONTaskWith:(NSURL *)URL JSONBody:(NSDictionary *)body {
    return [[[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(NSData * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
        request.HTTPMethod = @"POST";
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%ld", [request.HTTPBody length]] forHTTPHeaderField:@"Content-Length"];
        
        NSURLSessionDataTask *task = [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
           
            NSLog(@"response: %@", response);
            if (data) {
                fulfill(data);
            }
            else {
                reject(error);
            }
        }];
        
        [task resume];
        
    }] then:^id _Nullable(NSData * _Nonnull object) {
        return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(NSDictionary * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
            NSError *error = nil;
            NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:object options:0 error:&error];
            if (error) {
                reject(error);
            }
            else {
                fulfill(JSONDictionary);
            }
        }];
    }];
}

@end
