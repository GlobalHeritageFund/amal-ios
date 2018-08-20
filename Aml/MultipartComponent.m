//
//  MultipartComponent.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "MultipartComponent.h"

@interface MultipartComponent ()

@property (nonatomic, nonnull, readonly) NSData *data;
@property (nonatomic, nonnull, copy, readonly) NSString *name;
@property (nonatomic, nonnull, copy, readonly) NSString *fileName;
@property (nonatomic, nonnull, copy, readonly) NSString *contentType;

@end

@implementation MultipartComponent


- (nonnull instancetype)initWithData:(nonnull NSData *)data
                                name:(nonnull NSString *)name
                            fileName:(nullable NSString *)fileName
                         contentType:(nonnull NSString *)contentType {
    NSParameterAssert(data);
    NSParameterAssert(name);
    NSParameterAssert(contentType);
    self = [super init];
    
    if (self) {
        _data = data;
        _name = [name copy];
        _fileName = [fileName copy];
        _contentType = [contentType copy];
    }
    
    return self;
}

- (nonnull NSData *)dataRepresentationWithBoundary:(nonnull NSString *)boundary {
    NSParameterAssert(boundary);
    
    NSMutableData *bodyData = [[NSMutableData alloc] init];
    
    NSData *prefixData = ({
        NSMutableString *prefixString = [[NSMutableString alloc] init];
        
        [prefixString appendString:boundary];
        [prefixString appendString:@"\r\n"];
        
        [prefixString appendFormat:@"Content-Disposition: form-data; name=\"%@\"", self.name];
        
        if (self.fileName) {
            [prefixString appendFormat:@"; filename=\"%@\"", self.fileName];
        }
        
        [prefixString appendString:@"\r\n"];
        
        [prefixString appendFormat:@"Content-Type: %@", self.contentType];
        
        [prefixString appendString:@"\r\n"];
        [prefixString appendString:@"\r\n"];
        [prefixString dataUsingEncoding:NSUTF8StringEncoding];
    });
    
    if (prefixData) {
        [bodyData appendData:prefixData];
    }
    
    [bodyData appendData:self.data];
    
    NSData *CRLFData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    
    if (CRLFData) {
        [bodyData appendData:CRLFData];
    }
    
    return bodyData;
}

@end
