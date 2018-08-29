//
//  HerBridgePhoto.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/27/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "HerBridgePhoto.h"
#import "AMLMetadata.h"
#import "NSURLSession+Promises.h"

@interface HerBridgePhoto ()

@property (nonatomic, readonly) NSString *thumbnailURL;
@property (nonatomic, readonly) NSString *imageURL;

@end

@implementation HerBridgePhoto
@synthesize metadata = _metadata;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (!self) return nil;
    
    AMLMetadata *metadata = [[AMLMetadata alloc] init];
    
    metadata.interventionRequired = [dictionary[@"interventionRequired"] boolValue];
    
    NSDictionary *imageDictionary = [dictionary[@"images"] firstObject];
    
    metadata.longitude = [imageDictionary[@"longitude"] doubleValue];
    metadata.latitude = [imageDictionary[@"latitude"] doubleValue];
    metadata.localIdentifier = dictionary[@"id"];
    metadata.hazards = [dictionary[@"hazards"] boolValue];
    metadata.safetyHazards = [dictionary[@"safetyHazards"] boolValue];
    
    metadata.notes = dictionary[@"notes"];
    metadata.name = dictionary[@"name"];
    metadata.conditionNumber = [self conditionNumberFromConditionString:dictionary[@"condition"]];
    metadata.date = [NSDate dateWithTimeIntervalSince1970:[imageDictionary[@"captureDate"] doubleValue]];
    _metadata = metadata;
    
    _imageURL = imageDictionary[@"url"];
    _thumbnailURL = imageDictionary[@"thumbnailUrl"];
    
    return self;
}

- (int)conditionNumberFromConditionString:(NSString *)conditionString {
    
    if ([conditionString isEqualToString:@"unknown"]) {
        return 0;
    } else if ([conditionString isEqualToString:@"none"]) {
        return 1;
    } else if ([conditionString isEqualToString:@"minor"]) {
        return 2;
    } else if ([conditionString isEqualToString:@"moderate"]) {
        return 3;
    } else if ([conditionString isEqualToString:@"severe"]) {
        return 4;
    } else if ([conditionString isEqualToString:@"collapsed"]) {
        return 5;
    }
    
    return 0;
}

- (Promise *)loadFullSizeImage {
    return [[[NSURLSession sharedSession] taskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.imageURL]]] then:^id _Nullable(id  _Nonnull object) {
        return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(UIImage *_Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
            fulfill([[UIImage alloc] initWithData:object]);
        }];
    }];
}

- (Promise *)loadThumbnailImage {
    return [[[NSURLSession sharedSession] taskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.thumbnailURL]]] then:^id _Nullable(id  _Nonnull object) {
        return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(UIImage *_Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
            fulfill([[UIImage alloc] initWithData:object]);
        }];
    }];}

@end
