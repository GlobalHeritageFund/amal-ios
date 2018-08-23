//
//  RequestFactory.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Promise.h"

@interface RequestSender : NSObject

- (instancetype)initWithBaseURLString:(NSString *)baseURLString session:(NSURLSession *)session;

- (Promise <NSDictionary *> *)getRequestWithPath:(NSString *)path;
- (Promise <NSDictionary *> *)postRequest:(NSDictionary *)jsonDictionary path:(NSString *)path;

- (Promise <NSDictionary *> *)uploadImage:(UIImage *)image metadata:(NSDictionary *)metadata path:(NSString *)path;

@end
