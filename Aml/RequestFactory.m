//
//  RequestFactory.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/21/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "RequestFactory.h"
#import "MultipartComponent.h"
#import "NSURLSession+Promises.h"
#import "RequestBuilder.h"
#import "MultipartRequest.h"
#import "JSONRequest.h"

@interface RequestFactory ()

@property (nonatomic, readonly) NSString *baseURLString;
@property (nonatomic, readonly) NSURLSession *session;

@end

@implementation RequestFactory

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

    return [self.session taskWithRequest:[builder URLRequest]];
}

- (Promise <NSDictionary *> *)postRequest:(NSDictionary *)jsonDictionary path:(NSString *)path {
    JSONRequest *request = [[JSONRequest alloc] initWithJSONDictionary:jsonDictionary URLString:[self urlStringWithPath:path] requestType:HTTPMethodPOST];
    RequestBuilder *builder = [[RequestBuilder alloc] initWithRequest:request];
    
    return [self.session taskWithRequest:[builder URLRequest]];
}

- (Promise <NSDictionary *> *)uploadImage:(UIImage *)image metadata:(NSDictionary *)metadata path:(NSString *)path {
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
    MultipartComponent *imagePart = [[MultipartComponent alloc] initWithData:data name:@"image" fileName:@"image_1.jpg" contentType:@"image/jpeg"];
    
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
    
    return [self.session taskWithRequest:[builder URLRequest]];
}

@end
