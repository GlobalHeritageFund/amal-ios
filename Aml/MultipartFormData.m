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

- (nonnull NSString *)hyphenatedBoundary {
    return [@"--" stringByAppendingString:self.boundary];
}

- (nonnull NSInputStream *)inputStream {

    NSMutableArray *inputStreams = [@[] mutableCopy];
    
    for (MultipartComponent *bodyPart in self.parts) {
        [inputStreams addObject:[bodyPart inputStreamUsingBoundary:self.hyphenatedBoundary]];
    }
    
    NSData *finalBoundary = self.finalBoundary;
    
    if (finalBoundary) {
        [inputStreams addObject:[NSInputStream inputStreamWithData:finalBoundary]];
    }

    return [[NSSerialInputStream alloc] initWithInputStreams:inputStreams];
}

- (NSData *)finalBoundary {
    return [[NSString stringWithFormat:@"--%@--\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding];

}

- (NSUInteger)contentLength {
    NSUInteger length = 0;
    for (MultipartComponent *component in self.parts) {
        length += [component contentLengthWithBoundary:self.hyphenatedBoundary];
    }
    return length + self.finalBoundary.length;
}

@end
