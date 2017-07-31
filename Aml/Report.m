//
//  Report.m
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "Report.h"
#import "AMLMetadata.h"
#import "NSArray+Additions.h"

@implementation Image

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    _remoteStorageLocation = dictionary[@"imageRef"];
    _settings = [[AMLMetadata alloc] initWithDictionary:dictionary[@"settings"]];

    return self;
}

- (Promise *)fetchFirebaseImage {
    return [Promise rejected:[NSError errorWithDomain:@"asdf" code:123 userInfo:nil]];
}

@end

@implementation Report

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;

    _title = dictionary[@"title"];

    NSDictionary *images = dictionary[@"images"];
    _images = [images.allKeys arrayByTransformingObjectsUsingBlock:^id(id object) {
        return [[Image alloc] initWithDictionary:images[object]];
    }];

    return self;
}


@end
