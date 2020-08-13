//
//  PhotoSettings.h
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalPhoto, AMLMetadata;

@interface PhotoSettings : NSObject

+ (instancetype)shared;

@property (nonatomic) AMLMetadata *currentMetadata;

@end
