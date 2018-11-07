//
//  RequestBuilder.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "RequestBuilder.h"

@implementation RequestBuilder

- (instancetype)initWithRequest:(id <Request>)request {
    self = [super init];
    
    if (self) {
        _request = request;
    }
    
    return self;
}

- (NSDictionary *)headers {
    return @{
             @"Content-Type" : self.request.contentType,
             @"Accept" : @"application/json",
             @"Content-Length" : [NSString stringWithFormat:@"%tu", self.request.contentLength],
             };
}

- (NSURL *)URL {
    return [NSURL URLWithString:self.request.URLString];
}

- (NSURLRequest *)URLRequest {
    NSMutableURLRequest *URLRequest = [NSMutableURLRequest requestWithURL:[self URL]];
    URLRequest.HTTPMethod = [self methodStringFromMethodType:self.request.methodType];
    [self.headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [URLRequest addValue:obj forHTTPHeaderField:key];
    }];
    URLRequest.HTTPBodyStream = self.request.httpBodyStream;
    
    return [URLRequest copy];
}

- (NSString *)methodStringFromMethodType:(HTTPMethod)type {
    switch (type) {
        case HTTPMethodGET:
            return @"GET";
            break;
      case HTTPMethodPOST:
            return @"POST";
            break;
    }
}

@end
