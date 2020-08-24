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

    _name = [dictionary[@"name"] asClassOrNil:[NSString class]] ?: @"";
    _category = [dictionary[@"category"] asClassOrNil:[NSString class]] ?: @"";
    _levelOfDamage = [dictionary[@"levelOfDamage"] intValue];
    _conditionNumber = [dictionary[@"conditionNumber"] intValue];
    _hazards = [dictionary[@"hazards"] boolValue];
    _safetyHazards = [dictionary[@"safetyHazards"] boolValue];
    _interventionRequired = [dictionary[@"interventionRequired"] boolValue];
    _notes = [dictionary[@"notes"] asClassOrNil:[NSString class]] ?: @"";
    _latitude = [dictionary[@"lat"] doubleValue];
    _longitude = [dictionary[@"lon"] doubleValue];
    _date = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"date"] doubleValue]];
    _firebaseImageKey = [dictionary[@"firebaseImageKey"] asClassOrNil:[NSString class]] ?: @"unset";
    _localIdentifier = [dictionary[@"localIdentifier"] asClassOrNil:[NSString class]] ?: @"";

    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{
             @"name": self.name,
             @"category": self.category,
             @"levelOfDamage": @(self.levelOfDamage),
             @"conditionNumber": @(self.conditionNumber),
             @"hazards": @(self.hazards),
             @"safetyHazards": @(self.safetyHazards),
             @"interventionRequired": @(self.interventionRequired),
             @"notes": self.notes,
             @"lat": @(self.latitude),
             @"lon": @(self.longitude),
             @"date": @(self.date.timeIntervalSince1970),
             @"firebaseImageKey": self.firebaseImageKey,
             @"localIdentifier": self.localIdentifier,
             };
}

- (NSDictionary *)heritageDictionaryRepresentation {
    return @{
             @"latitude" : @(self.latitude),
             @"longitude" : @(self.longitude),
             @"caption" : self.notes,
             @"captureDate" : @(self.date.timeIntervalSince1970),
             };
}

- (NSString *)locationString {
    if (self.hasLocationCoordinates) {
        return [NSString stringWithFormat:@"%f, %f", self.latitude, self.longitude];
    }
    return @"No coordinates.";
}

- (BOOL)hasLocationCoordinates {
    return fabs(self.latitude) > 0.1 || fabs(self.longitude) > 0.1;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (NSString *)category {
    if (_category.length == 0) {
        return @"unknown";
    }
    return _category;
}

- (NSString *)condition {
    switch (self.conditionNumber) {
        case 0:
            return @"unknown";
        case 1:
            return @"none";
        case 2:
            return @"minor";
        case 3:
            return @"moderate";
        case 4:
            return @"severe";
        case 5:
            return @"collapsed";
    }
    
    return @"unknown";
}

- (NSString *)localizedCondition {
    switch (self.conditionNumber) {
        case 0:
            return NSLocalizedString(@"unknown", @"");
        case 1:
            return NSLocalizedString(@"none", @"");
        case 2:
            return NSLocalizedString(@"minor", @"");
        case 3:
            return NSLocalizedString(@"moderate", @"");
        case 4:
            return NSLocalizedString(@"severe", @"");
        case 5:
            return NSLocalizedString(@"collapsed", @"");
    }

    return NSLocalizedString(@"unknown", @"");
}

- (NSString *)localizedCategory {
    if ([self.category isEqualToString:@"area"]) {
        return NSLocalizedString(@"area", @"");
    }
    if ([self.category isEqualToString:@"site"]) {
        return NSLocalizedString(@"site", @"");
    }

    if ([self.category isEqualToString:@"object"]) {
        return NSLocalizedString(@"object", @"");
    }
    return NSLocalizedString(@"unknown", @"");
}


@end
