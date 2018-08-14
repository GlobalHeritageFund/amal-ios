//
//  NSURLSession+Promises.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSURLSession+Promises.h"
#import "MultipartPart.h"
#import "MultipartFormData.h"

@implementation NSURLSession (Promises)

- (Promise <NSDictionary *> *)POSTImageTo:(NSURL *)URL image:(UIImage *)image metadata:(NSDictionary *)metadata {
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSData *settings = [NSJSONSerialization dataWithJSONObject:metadata options:0 error:nil];

    MultipartPart *imagePart = [[MultipartPart alloc] initWithData:data name:@"image" fileName:@"image_1.jpg" contentType:@"image/jpeg"];
    MultipartPart *settingsPart = [[MultipartPart alloc] initWithData:settings name:@"settings" fileName:nil contentType:@"application/json"];
    
    return [self POSTMultipartWithURL:URL multiparts:@[settingsPart, imagePart]];
}

- (Promise <NSDictionary *> *)POSTMultipartWithURL:(NSURL *)URL multiparts:(NSArray <MultipartPart *> *)parts {
    MultipartFormData *multipartData = [[MultipartFormData alloc] initWithParts:parts boundary:@"AMALBoundary"];
    NSData *data = [multipartData dataRepresentation];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    request.HTTPBody = data;
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"multipart/form-data; charset=utf-8; boundary=\"AMALBoundary\"" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", [request.HTTPBody length]] forHTTPHeaderField:@"Content-Length"];

    return [[self POSTTaskWithURL:URL request:request] then:^id _Nullable(NSData * _Nonnull object) {
        return [self JSONDictionaryFromData:object];
    }];
}

- (Promise <NSDictionary *> *)POSTJSONTaskWith:(NSURL *)URL JSONBody:(NSDictionary *)body {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    request.HTTPMethod = @"POST";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%ld", [request.HTTPBody length]] forHTTPHeaderField:@"Content-Length"];
    
    return [[self POSTTaskWithURL:URL request:request] then:^id _Nullable(NSData * _Nonnull object) {
        return [self JSONDictionaryFromData:object];
    }];
}

- (Promise <NSDictionary *> *)POSTTaskWithURL:(NSURL *)URL request:(NSURLRequest *)request {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(NSData * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        
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
    }];
}

- (Promise <NSDictionary *> *)JSONDictionaryFromData:(NSData *)data {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(NSDictionary * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        NSError *error = nil;
        NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            reject(error);
        }
        else {
            fulfill(JSONDictionary);
        }
    }];
}

@end
