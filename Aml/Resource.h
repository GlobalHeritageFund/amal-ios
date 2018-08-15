//
//  Resource.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/15/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UploadedPhoto.h"
#import "Promise.h"

@interface Resource : NSObject

@property (nonatomic, readonly) UploadedPhoto *uploadedPhoto;
@property (nonatomic, readonly) NSString *identifier;

- (instancetype)initWithUploadedPhoto:(UploadedPhoto *)uploadedPhoto identifier:(NSString *)identifier;

+ (Promise <Resource *>*)resourceWithDictionary:(NSDictionary *)dictionary uploadedPhoto:(UploadedPhoto *)uploadedPhoto;

@end
