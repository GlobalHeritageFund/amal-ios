//
//  UploadedPhoto.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "UploadedPhoto.h"
#import "AMLMetadata.h"

@implementation UploadedPhoto

- (instancetype)initWithIdentifier:(NSString *)identifier thumbnailURL:(NSString *)thumbnailURL URL:(NSString *)URL localPhoto:(LocalPhoto *)localPhoto {
    self = [super init];
    if (!self) return nil;
    
    _identifier = identifier;
    _thumbnailURL = thumbnailURL;
    _URL = URL;
    _localPhoto = localPhoto;
    
    return self;
}

+ (Promise <UploadedPhoto *> *)uploadedPhotoFrom:(NSDictionary *)dictionary localPhoto:(LocalPhoto *)localPhoto {
    
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(UploadedPhoto * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        
        NSString *thumbnailURL = dictionary[@"thumbnailUrl"];
        NSString *url = dictionary[@"url"];
        NSString *identifier = dictionary[@"id"];
        
        if (url && thumbnailURL && identifier) {
            fulfill([[UploadedPhoto alloc] initWithIdentifier:identifier thumbnailURL:thumbnailURL URL:url localPhoto:localPhoto]);
        } else {
            reject([NSError errorWithDomain:@"com.amal.uploadedphoto" code:1 userInfo:nil]);
        }
    }];
    
}

- (NSDictionary *)dictionaryRepresentation {
    
    return @{
        @"name" : self.localPhoto.metadata.name,
        @"notes" : self.localPhoto.metadata.notes,
        @"condition" : self.localPhoto.metadata.condition,
        @"type" : self.localPhoto.metadata.category,
        @"hazards" : @(self.localPhoto.metadata.hazards),
        @"safetyHazards" : @(self.localPhoto.metadata.safetyHazards),
        @"interventionRequired" : @(self.localPhoto.metadata.interventionRequired),
        @"images" : @[
                self.identifier
        ]
    };
}

- (NSDictionary *)heritageReportRepresentation {
    NSMutableDictionary *representation = [self.dictionaryRepresentation mutableCopy];
    representation[@"type"] = [self convertTypeToBeHerBridgeFriendly:representation[@"type"]];
    return representation;
}

- (NSString *)convertTypeToBeHerBridgeFriendly:(NSString *)oldType {
    if ([oldType isEqualToString:@"area"]) {
        return @"area";
    }
    if ([oldType isEqualToString:@"site"]) {
        return @"building";
    }
    if ([oldType isEqualToString:@"object"]) {
        return @"object";
    }
    return @"unknown";
}

@end
