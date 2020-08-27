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
            if (error) {
                reject(error);
            } else if(!(URLResponse.statusCode >= 200 && URLResponse.statusCode < 300)) {
                NSString *errorString = @"The body was empty.";
                NSString *body = [[NSString alloc] initWithData:data encoding:kCFStringEncodingUTF8];
                if (body != nil) {
                    errorString = [NSString stringWithFormat:@"The error was %@.", body];
                }
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The operation failed with a status code of %zd. %@", URLResponse.statusCode, errorString],
                };
                reject([NSError errorWithDomain:@"NSURLSessionStatusCodeError" code:URLResponse.statusCode userInfo:userInfo]);
            } else if (data) {
                fulfill(data);
            } else {
                [[NSException exceptionWithName:@"URLSessionException" reason:@"Something has gone horribly wrong." userInfo:nil] raise];
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
