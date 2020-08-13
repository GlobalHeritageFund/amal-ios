//
//  MultipartComponent.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultipartComponent : NSObject

- (nonnull instancetype)initWithFileURL:(nonnull NSURL *)url
                                   name:(nonnull NSString *)name
                               fileName:(nullable NSString *)fileName
                            contentType:(nonnull NSString *)contentType;

- (nonnull instancetype)initWithData:(nonnull NSData *)data
                                name:(nonnull NSString *)name
                            fileName:(nullable NSString *)fileName
                         contentType:(nonnull NSString *)contentType;

- (nonnull NSInputStream *)inputStreamUsingBoundary:(nonnull NSString *)boundary;

- (NSUInteger)contentLengthWithBoundary:(NSString *_Nonnull)boundary;

@end
