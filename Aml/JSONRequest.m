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
        _JSONDictionary = JSONDictionary;
        _URLString = URLString;
        _methodType = requestType;
    }
    
    return self;
}

- (NSString *)contentType {
    return @"application/json";
}

- (NSData *)httpBody {
    
    if (self.methodType == HTTPMethodGET) {
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:self.JSONDictionary options:0 error:nil];
}

@end
