//
//  LocalPhotoFilter.h
//  Amal
//
//  Created by Soroush Khanlou on 1/2/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalPhoto;

@protocol LocalPhotoFilter

- (BOOL)shouldIncludePhoto:(LocalPhoto *)photo;

@end

@interface DefaultPhotoFilter : NSObject <LocalPhotoFilter>

@end

@interface UnassessedPhotoFilter : NSObject <LocalPhotoFilter>

@end

@interface AssessedPhotoFilter : NSObject <LocalPhotoFilter>

@end

