//
//  UploadedPhoto.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"
#import "LocalPhoto.h"

@interface UploadedPhoto : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier thumbnailURL:(NSString *)thumbnailURL URL:(NSString *)URL localPhoto:(LocalPhoto *)localPhoto;

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *thumbnailURL;
@property (nonatomic, readonly) NSString *URL;
@property (nonatomic, readonly) LocalPhoto *localPhoto;

+ (Promise <UploadedPhoto *> *)uploadedPhotoFrom:(NSDictionary *)dictionary localPhoto:(LocalPhoto *)localPhoto;

- (NSDictionary *)dictionaryRepresentation;

@end
