//
//  PhotoSettings.h
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoSettings : NSObject

+ (instancetype)shared;

- (void)savePhoto:(UIImage*)image;

@property (strong) NSNumber *category; // int
@property (strong) NSNumber *condition; // int
@property (strong) NSNumber *levelOfDamage; // float
@property (strong) NSNumber *hazards; // bool
@property (strong) NSNumber *safetyHazards; // bool
@property (strong) NSNumber *intervention; // bool
@property (strong) NSString *notes;

- (void)clearSettings;

@end
