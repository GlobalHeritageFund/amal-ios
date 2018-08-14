//
//  MultipartFormData.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "MultipartFormData.h"
#import "MultipartPart.h"

@interface MultipartFormData ()

@property (nonatomic, nonnull, copy, readonly) NSArray <MultipartPart *> *parts;
@property (nonatomic, nonnull, copy, readonly) NSString *boundary;

@end

@implementation MultipartFormData

- (nonnull instancetype)initWithParts:(nonnull NSArray <MultipartPart *> *)parts boundary:(nonnull NSString *)boundary {
    NSParameterAssert(parts);
    NSParameterAssert(boundary);
    self = [super init];
    
    if (self) {
        _parts = [parts copy];
        _boundary = [boundary copy];
    }
    
    return self;
}

- (nonnull NSData *)dataRepresentation {
    NSMutableData *data = [[NSMutableData alloc] init];
    
    // Maps all the current body parts to data and appends to the mutable data.
    {
        NSString *boundary = self.boundary;
        for (MultipartPart *bodyPart in self.parts) {
            [data appendData:[bodyPart dataRepresentationWithBoundary:[@"--" stringByAppendingString:boundary]]];
        }
    }
    
    NSData *boundaryData = [[NSString stringWithFormat:@"--%@--", self.boundary] dataUsingEncoding:NSUTF8StringEncoding];
    
    if (boundaryData) {
        [data appendData:boundaryData];
    }
    
    NSData *CRLFData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    
    if (CRLFData) {
        [data appendData:CRLFData];
    }
    
    return data;
}

@end
