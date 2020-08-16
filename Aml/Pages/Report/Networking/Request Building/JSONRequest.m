//
//  JSONRequest.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "JSONRequest.h"

@interface JSONRequest ()

@property (nonatomic, readonly) NSDictionary *JSONDictionary;

@end

@implementation JSONRequest

@synthesize methodType = _methodType;
@synthesize URLString = _URLString;

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary URLString:(NSString *)URLString requestType:(HTTPMethod)requestType {
    self = [super init];
    
    if (self) {
        _JSONDictionary = [JSONDictionary copy];
        _URLString = [URLString copy];
        _methodType = requestType;
    }
    
    return self;
}

- (NSString *)contentType {
    return @"application/json";
}

- (NSData *)data {
    if (self.methodType == HTTPMethodGET) {
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:self.JSONDictionary options:0 error:nil];
}

- (NSInputStream *)httpBodyStream {
    return [NSInputStream inputStreamWithData:self.data];
}

- (NSUInteger)contentLength {
    return self.data.length;
}

@end