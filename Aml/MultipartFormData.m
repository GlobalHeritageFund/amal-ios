//
//  MultipartFormData.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "MultipartFormData.h"
#import "MultipartComponent.h"
#import "NSSerialInputStream.h"

@interface MultipartFormData ()

@property (nonatomic, nonnull, copy, readonly) NSArray <MultipartComponent *> *parts;
@property (nonatomic, nonnull, copy, readonly) NSString *boundary;

@end

@implementation MultipartFormData

- (nonnull instancetype)initWithParts:(nonnull NSArray <MultipartComponent *> *)parts boundary:(nonnull NSString *)boundary {
    NSParameterAssert(parts);
    NSParameterAssert(boundary);
    self = [super init];
    
    if (self) {
        _parts = [parts copy];
        _boundary = [boundary copy];
    }
    
    return self;
}

- (nonnull NSInputStream *)inputStream {

    NSMutableArray *inputStreams = [@[] mutableCopy];
    NSString *boundary = self.boundary;
    
    for (MultipartComponent *bodyPart in self.parts) {
        [inputStreams addObject:[bodyPart inputStreamUsingBoundary:[@"--" stringByAppendingString:boundary]]];
    }
    
    NSData *boundaryData = [[NSString stringWithFormat:@"--%@--", self.boundary] dataUsingEncoding:NSUTF8StringEncoding];
    
    if (boundaryData) {
        [inputStreams addObject:[NSInputStream inputStreamWithData:boundaryData]];
    }
    
    NSData *CRLFData = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    
    if (CRLFData) {
        [inputStreams addObject:[NSInputStream inputStreamWithData:CRLFData]];
    }
    
    return [[NSSerialInputStream alloc] initWithInputStreams:inputStreams];
}

@end
