//
//  MultipartRequest.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "MultipartRequest.h"
#import "MultipartFormData.h"

@interface MultipartRequest ()

@property (nonatomic, readonly) NSString *boundary;
@property (nonatomic, readonly, copy) NSArray <MultipartComponent *> *parts;

@end

@implementation MultipartRequest

@synthesize methodType;
@synthesize URLString = _URLString;

- (instancetype)initWithBoundary:(NSString *)boundary parts:(NSArray <MultipartComponent *> *)parts URLString:(NSString *)URLString {
    self = [super init];
    
    if (self) {
        _boundary = boundary;
        _parts = [parts copy];
        _URLString = URLString;
    }
    
    return self;
}

- (NSString *)contentType {
    return [NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=\"%@\"", self.boundary];
}

- (NSData *)httpBody {
    return [[[MultipartFormData alloc] initWithParts:self.parts boundary:self.boundary] dataRepresentation];
}

- (HTTPMethod)methodType {
    return HTTPMethodPOST;
}

@end
