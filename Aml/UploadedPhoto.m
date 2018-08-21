//
//  UploadedPhoto.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "UploadedPhoto.h"

@implementation UploadedPhoto

- (instancetype)initWithIdentifier:(NSString *)identifier thumbnailURL:(NSString *)thumbnailURL URL:(NSString *)URL photoUpload:(PhotoUpload *)photoUpload {
    self = [super init];
    if (!self) return nil;
    
    _identifier = identifier;
    _thumbnailURL = thumbnailURL;
    _URL = URL;
    _photoUpload = photoUpload;
    
    return self;
}

+ (Promise <UploadedPhoto *> *)uploadedPhotoFrom:(NSDictionary *)dictionary photoUpload:(PhotoUpload *)photoUpload {
    
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(UploadedPhoto * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        
        NSString *thumbnailURL = dictionary[@"thumbnailUrl"];
        NSString *url = dictionary[@"url"];
        NSString *identifier = dictionary[@"id"];
        
        if (url && thumbnailURL && identifier) {
            fulfill([[UploadedPhoto alloc] initWithIdentifier:identifier thumbnailURL:thumbnailURL URL:url photoUpload:photoUpload]);
        } else {
            reject([NSError errorWithDomain:@"com.amal.uploadedphoto" code:1 userInfo:nil]);
        }
    }];
    
}

- (NSDictionary *)dictionaryRepresentation {
    
    return @{
      @"name" : self.photoUpload.metadata.name,
      @"notes" : self.photoUpload.metadata.notes,
      @"condition" : self.photoUpload.metadata.condition,
      @"type" : self.photoUpload.metadata.category,
      @"hazards" : @(self.photoUpload.metadata.hazards),
      @"safetyHazards" : @(self.photoUpload.metadata.safetyHazards),
      @"interventionRequired" : @(self.photoUpload.metadata.interventionRequired),
      @"images" : @[
              self.identifier
              ]
      };
}

@end
