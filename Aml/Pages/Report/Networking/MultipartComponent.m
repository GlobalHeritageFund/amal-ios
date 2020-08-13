//
//  MultipartComponent.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "MultipartComponent.h"
#import "NSSerialInputStream.h"

@interface MultipartComponent ()

@property (nonatomic, nonnull, readonly) NSInputStream *dataStream;
@property (nonatomic, nonnull, copy, readonly) NSString *name;
@property (nonatomic, nonnull, copy, readonly) NSString *fileName;
@property (nonatomic, nonnull, copy, readonly) NSString *contentType;
@property (nonatomic) NSUInteger streamLength;

@end

@implementation MultipartComponent

- (nonnull instancetype)initWithFileURL:(nonnull NSURL *)URL
                                   name:(nonnull NSString *)name
                               fileName:(nullable NSString *)fileName
                            contentType:(nonnull NSString *)contentType {
    NSParameterAssert(URL);
    NSParameterAssert(name);
    NSParameterAssert(contentType);
    self = [super init];
    
    if (self) {
        _dataStream = [NSInputStream inputStreamWithURL:URL];
        _name = [name copy];
        _fileName = [fileName copy];
        _contentType = [contentType copy];
        
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[URL path] error:nil];
        _streamLength = [fileAttributes[NSFileSize] unsignedIntegerValue];

    }
    
    return self;
}

- (nonnull instancetype)initWithData:(nonnull NSData *)data
                                name:(nonnull NSString *)name
                            fileName:(nullable NSString *)fileName
                         contentType:(nonnull NSString *)contentType {
    NSParameterAssert(data);
    NSParameterAssert(name);
    NSParameterAssert(contentType);
    self = [super init];
    
    if (self) {
        _dataStream = [NSInputStream inputStreamWithData:data];
        _name = [name copy];
        _fileName = [fileName copy];
        _contentType = [contentType copy];
        _streamLength = data.length;
    }
    
    return self;
}

- (nonnull NSInputStream *)inputStreamUsingBoundary:(nonnull NSString *)boundary {
    NSParameterAssert(boundary);
    
    NSArray *streams = @[
                         [NSInputStream inputStreamWithData:[self prefixDataWithBoundary:boundary]],
                         self.dataStream,
                         [NSInputStream inputStreamWithData:[self postfixDataWithBoundary:boundary]],
                         ];
    
    return [[NSSerialInputStream alloc] initWithInputStreams:streams];
}

- (NSUInteger)contentLengthWithBoundary:(NSString *)boundary; {
    return [self prefixDataWithBoundary:boundary].length
    + self.streamLength
    + [self postfixDataWithBoundary:boundary].length;
}

- (NSData *)prefixDataWithBoundary:(NSString *)boundary {
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
    return [prefixString dataUsingEncoding:NSUTF8StringEncoding];
    
}

- (NSData *)postfixDataWithBoundary:(NSString *)boundary {
    return [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
}

@end
