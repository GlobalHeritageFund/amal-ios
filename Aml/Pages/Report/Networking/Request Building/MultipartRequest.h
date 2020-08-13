//
//  MultipartRequest.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultipartComponent.h"
#import "Request.h"

@interface MultipartRequest : NSObject <Request>

- (instancetype)initWithBoundary:(NSString *)boundary parts:(NSArray <MultipartComponent *> *)parts URLString:(NSString *)URLString;

@end
