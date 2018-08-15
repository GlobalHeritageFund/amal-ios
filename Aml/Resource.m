//
//  Resource.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/15/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "Resource.h"

@implementation Resource

- (instancetype)initWithUploadedPhoto:(UploadedPhoto *)uploadedPhoto identifier:(NSString *)identifier {
    self = [super init];
    
    if (self) {
        _uploadedPhoto = uploadedPhoto;
        _identifier = identifier;
    }
    
    return self;
}

+ (Promise <Resource *>*)resourceWithDictionary:(NSDictionary *)dictionary uploadedPhoto:(UploadedPhoto *)uploadedPhoto {
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(Resource * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        NSString *identifier = dictionary[@"id"];
        
        if (identifier) {
            fulfill([[Resource alloc] initWithUploadedPhoto:uploadedPhoto identifier:identifier]);
        }
        else {
            reject([NSError errorWithDomain:@"com.amal.resource" code:1 userInfo:nil]);
        }
    }];
}

@end
