//
//  RequestBuilder.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"

@interface RequestBuilder : NSObject

- (instancetype)initWithRequest:(id <Request>)request;

@property (nonatomic, readonly) id <Request> request;

- (NSURLRequest *)URLRequest;

@end
