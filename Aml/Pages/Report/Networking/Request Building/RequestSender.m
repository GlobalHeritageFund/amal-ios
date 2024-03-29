//
//  RequestFactory.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "RequestSender.h"
#import "MultipartComponent.h"
#import "NSURLSession+Promises.h"
#import "RequestBuilder.h"
#import "MultipartRequest.h"
#import "JSONRequest.h"

@interface RequestSender ()

@property (nonatomic, readonly) NSString *baseURLString;
@property (nonatomic, readonly) NSURLSession *session;

@end

@implementation RequestSender

- (instancetype)initWithBaseURLString:(NSString *)baseURLString session:(NSURLSession *)session {
    self = [super init];
    
    if (self) {
        _baseURLString = baseURLString;
        _session = session;
    }
    
    return self;
}

- (NSString *)urlStringWithPath:(NSString *)path {
    return [self.baseURLString stringByAppendingString:path];
}

- (Promise <NSDictionary *> *)getRequestWithPath:(NSString *)path {
    JSONRequest *request = [[JSONRequest alloc] initWithJSONDictionary:nil URLString:[self urlStringWithPath:path] requestType:HTTPMethodGET];
    RequestBuilder *builder = [[RequestBuilder alloc] initWithRequest:request];

    return [self.session JSONtaskWithRequest:[builder URLRequest]];
}

- (Promise <NSDictionary *> *)postRequest:(NSDictionary *)jsonDictionary path:(NSString *)path {
    JSONRequest *request = [[JSONRequest alloc] initWithJSONDictionary:jsonDictionary URLString:[self urlStringWithPath:path] requestType:HTTPMethodPOST];
    RequestBuilder *builder = [[RequestBuilder alloc] initWithRequest:request];
    
    return [self.session JSONtaskWithRequest:[builder URLRequest]];
}

- (Promise <NSDictionary *> *)uploadFile:(NSURL *)url metadata:(NSDictionary *)metadata path:(NSString *)path {
    
    MultipartComponent *imagePart = [[MultipartComponent alloc] initWithFileURL:url name:@"image" fileName:@"image_1.jpg" contentType:@"image/jpeg"];
    
    NSMutableArray *parts = [[NSMutableArray alloc] initWithObjects:imagePart, nil];
    
    for (NSString *key in [metadata allKeys]) {
        
        id value = metadata[key];
        
        if ([value isKindOfClass:[NSNumber class]]) {
            value = [value stringValue];
        }
        
        NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
        MultipartComponent *part = [[MultipartComponent alloc] initWithData:data name:key fileName:nil contentType:@"text/plain"];
        
        [parts addObject:part];
    }
    
    MultipartRequest *request = [[MultipartRequest alloc] initWithBoundary:@"AMALBoundary" parts:parts URLString:[self urlStringWithPath:path]];
    RequestBuilder *builder = [[RequestBuilder alloc] initWithRequest:request];
    
    return [self.session JSONtaskWithRequest:[builder URLRequest]];
}

@end
