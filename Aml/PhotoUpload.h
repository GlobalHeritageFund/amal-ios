//
//  PhotoUpload.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMLMetadata.h"
#import "Promise.h"

@interface PhotoUpload : NSObject

- (instancetype)initWithImage:(UIImage *)image metadata:(AMLMetadata *)metadata;

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) AMLMetadata *metadata;

@end
