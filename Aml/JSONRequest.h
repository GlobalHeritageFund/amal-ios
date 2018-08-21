//
//  JSONRequest.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Request.h"

@interface JSONRequest : NSObject <Request>

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary
                             URLString:(NSString *)URLString
                           requestType:(HTTPMethod)requestType;

@end
