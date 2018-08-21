//
//  Request.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#ifndef Request_h
#define Request_h

typedef NS_ENUM(NSUInteger, HTTPMethod) {
    HTTPMethodGET,
    HTTPMethodPOST,
};


@protocol Request

@property (nonatomic, readonly) NSString *URLString;

@property (nonatomic, readonly) HTTPMethod methodType;

@property (nonatomic, readonly) NSString *contentType;

@property (nonatomic, readonly) NSData *httpBody;

@end


#endif /* Request_h */
