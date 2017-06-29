//
//  AMLMetadata.m
//  Amal
//
//  Created by Soroush Khanlou on 6/28/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "AMLMetadata.h"

@implementation AMLMetadata

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (!self) return nil;

    _category = dictionary[@"category"];
    _condition = dictionary[@"condition"];
    _levelOfDamage = [dictionary[@"levelOfDamage"] intValue];
    _hazards = [dictionary[@"hazards"] boolValue];
    _levelOfDamage = [dictionary[@"safetyHazards"] boolValue];
    _interventionRequired = [dictionary[@"interventionRequired"] boolValue];
    _notes = dictionary[@"notes"];
    _latitude = [dictionary[@"latitude"] doubleValue];
    _longitude = [dictionary[@"longitude"] doubleValue];

    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
             @"category": self.category,
             @"condition": self.condition,
             @"levelOfDamage": @(self.levelOfDamage),
             @"hazards": @(self.hazards),
             @"levelOfDamage": @(self.levelOfDamage),
             @"interventionRequired": @(self.interventionRequired),
             @"notes": self.notes,
             @"latitude": @(self.latitude),
             @"longitude": @(self.longitude),
             };
}


@end
