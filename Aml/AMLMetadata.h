//
//  AMLMetadata.h
//  Amal
//
//  Created by Soroush Khanlou on 6/28/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AMLMetadata : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *category;
@property (nonatomic) int levelOfDamage;
@property (nonatomic) int conditionNumber;
@property (nonatomic) BOOL hazards;
@property (nonatomic) BOOL safetyHazards;
@property (nonatomic) BOOL interventionRequired;
@property (nonatomic) NSString *notes;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSString *firebaseImageKey;
@property (nonatomic) NSString *localIdentifier;

@property (nonatomic, readonly) NSString *condition;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionaryRepresentation;
- (NSDictionary *)heritageDictionaryRepresentation;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (readonly) BOOL hasLocationCoordinates;
@property (readonly) NSString *locationString;
;

@end
