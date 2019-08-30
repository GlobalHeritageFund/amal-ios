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

@property (nonatomic, readonly) MultipartFormData *formData;
@property (nonatomic, readonly, copy) NSArray <MultipartComponent *> *parts;

@end

@implementation MultipartRequest

@synthesize methodType;
@synthesize URLString = _URLString;

- (instancetype)initWithBoundary:(NSString *)boundary parts:(NSArray <MultipartComponent *> *)parts URLString:(NSString *)URLString {
    self = [super init];
    
    if (self) {
        _formData = [[MultipartFormData alloc] initWithParts:parts boundary:boundary];
        _URLString = [URLString copy];
    }
    
    return self;
}

- (NSString *)contentType {
    return [NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=\"%@\"", self.boundary];
}

- (NSInputStream *)httpBodyStream {
    return [self.formData inputStream];
}

- (HTTPMethod)methodType {
    return HTTPMethodPOST;
}

- (NSUInteger)contentLength {
    return self.formData.contentLength;
}

@end
