//
//  UploadedPhoto.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "UploadedPhoto.h"

@implementation UploadedPhoto

- (instancetype)initWithThumbnailURL:(NSString *)thumbnailURL URL:(NSString *)URL photoUpload:(PhotoUpload *)photoUpload {
    self = [super init];
    
    if (self) {
        _thumbnailURL = thumbnailURL;
        _URL = URL;
        _photoUpload = photoUpload;
    }
    
    return self;
}

+ (Promise <UploadedPhoto *> *)uploadedPhotoFrom:(NSDictionary *)dictionary photoUpload:(PhotoUpload *)photoUpload {
    
    return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(UploadedPhoto * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
        
        NSString *thumbnailURL = dictionary[@"thumbnailUrl"];
        NSString *url = dictionary[@"url"];
        
        if (url && thumbnailURL) {
            fulfill([[UploadedPhoto alloc] initWithThumbnailURL:thumbnailURL URL:url photoUpload:photoUpload]);
        }
        else {
            reject([NSError errorWithDomain:@"com.amal.uploadedphoto" code:1 userInfo:nil]);
        }
    }];
    
}

@end
