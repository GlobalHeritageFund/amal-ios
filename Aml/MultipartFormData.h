//
//  MultipartFormData.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MultipartComponent;
@interface MultipartFormData : NSObject

- (nonnull instancetype)initWithParts:(nonnull NSArray <MultipartComponent *> *)parts boundary:(nonnull NSString *)boundary;

- (nonnull NSData *)dataRepresentation;

@end
