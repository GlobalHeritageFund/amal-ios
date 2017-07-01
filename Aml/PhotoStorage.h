//
//  PhotoStorage.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalPhoto, AMLMetadata;

@interface PhotoSection : NSObject

@property (nonatomic) NSString *header;
@property (nonatomic) NSArray *photos;

@end

@interface PhotoStorage : NSObject

// Saves the jpeg data locally, using the default photo settings.
- (LocalPhoto*)saveJpegLocally:(NSData*)jpegData withMetadata:(AMLMetadata *)metadata;

// This return an array of LocalPhotos that need 'load:' called individually.
- (NSArray<LocalPhoto *>*)fetchPhotos;

- (NSArray<PhotoSection *> *)fetchGroupedPhotos;

@end
