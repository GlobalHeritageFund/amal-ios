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

@property NSString *name;
@property (nonatomic) NSString *category;
@property int levelOfDamage;
@property int conditionNumber;
@property BOOL hazards;
@property BOOL safetyHazards;
@property BOOL interventionRequired;
@property NSString *notes;
@property double latitude;
@property double longitude;
@property NSDate *date;
@property NSString *firebaseImageKey;
@property NSString *localIdentifier;

@property (nonatomic, readonly) NSString *condition;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)dictionaryRepresentation;
- (NSDictionary *)heritageDictionaryRepresentation;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (readonly) BOOL hasLocationCoordinates;
@property (readonly) NSString *locationString;
;

@end
