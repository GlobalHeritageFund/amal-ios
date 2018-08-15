//
//  PhotoUpload.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "PhotoUpload.h"

@implementation PhotoUpload

- (instancetype)initWithImage:(UIImage *)image metadata:(AMLMetadata *)metadata {
    self = [super init];
    
    if (self) {
        _image = image;
        _metadata = metadata;
    }
    
    return self;
}

@end
