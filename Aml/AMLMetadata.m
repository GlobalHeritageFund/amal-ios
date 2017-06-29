//
//  AMLMetadata.m
//  Amal
//
//  Created by Soroush Khanlou on 6/28/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "AMLMetadata.h"
#import "NSObject+Helpers.h"

@implementation AMLMetadata

- (instancetype)init {
    return [self initWithDictionary:@{}];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {

    self = [super init];
    if (!self) return nil;

    _category = [dictionary[@"category"] asClassOrNil:[NSString class]] ?: @"";
    _condition = [dictionary[@"condition"]  asClassOrNil:[NSString class]] ?: @"";
    _levelOfDamage = [dictionary[@"levelOfDamage"] intValue];
    _hazards = [dictionary[@"hazards"] boolValue];
    _safetyHazards = [dictionary[@"safetyHazards"] boolValue];
    _interventionRequired = [dictionary[@"interventionRequired"] boolValue];
    _notes = [dictionary[@"notes"] asClassOrNil:[NSString class]] ?: @"";
    _latitude = [dictionary[@"lat"] doubleValue];
    _longitude = [dictionary[@"lon"] doubleValue];
    _date = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"date"] doubleValue]];
    _firebaseImageKey = [dictionary[@"firebaseImageKey"] asClassOrNil:[NSString class]] ?: @"unset";

    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
             @"category": self.category,
             @"condition": self.condition,
             @"levelOfDamage": @(self.levelOfDamage),
             @"hazards": @(self.hazards),
             @"safetyHazards": @(self.safetyHazards),
             @"interventionRequired": @(self.interventionRequired),
             @"notes": self.notes,
             @"lat": @(self.latitude),
             @"lon": @(self.longitude),
             @"date": @(self.date.timeIntervalSince1970),
             @"firebaseImageKey": self.firebaseImageKey,
             };
}

@end
