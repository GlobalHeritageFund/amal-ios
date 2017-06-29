//
//  AMLMetadata.h
//  Amal
//
//  Created by Soroush Khanlou on 6/28/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMLMetadata : NSObject

@property NSString *category;
@property NSString *condition;
@property int levelOfDamage;
@property BOOL hazards;
@property BOOL safetyHazards;
@property BOOL interventionRequired;
@property NSString *notes;
@property double latitude;
@property double longitude;
@property NSDate *date;


@end
