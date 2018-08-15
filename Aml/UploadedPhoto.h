//
//  UploadedPhoto.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"
#import "PhotoUpload.h"

@interface UploadedPhoto : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier thumbnailURL:(NSString *)thumbnailURL URL:(NSString *)URL photoUpload:(PhotoUpload *)photoUpload;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *thumbnailURL;
@property (nonatomic, readonly) NSString *URL;
@property (nonatomic, readonly) PhotoUpload *photoUpload;

+ (Promise <UploadedPhoto *> *)uploadedPhotoFrom:(NSDictionary *)dictionary photoUpload:(PhotoUpload *)photoUpload;

- (NSDictionary *)dictionaryRepresentation;

@end
