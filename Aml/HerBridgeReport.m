//
//  HerBridgeReport.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/20/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "HerBridgeReport.h"
#import "NSObject+Helpers.h"

@implementation HerBridgeReport

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
        _title = dictionary[@"title"];
        _assessorEmail = dictionary[@"assessor"][@"email"];
        
        NSTimeInterval created = [[dictionary[@"createdAt"] asClassOrNil:[NSNumber class]] doubleValue];
        _creationDate = [NSDate dateWithTimeIntervalSince1970:created];
        
    }
    
    return self;
}

- (NSString *)firebaseID {
    return nil;
}

- (NSInteger)photoCount {
    return self.photos.count;
}

- (BOOL)isEditable {
    return NO;
}

- (NSString *)email {
    if (self.assessorEmail.length) {
        return self.assessorEmail;
    } else {
        return @"No email set.";
    }
}

- (NSDate *)minDate {
    return [self.photos valueForKeyPath:@"@min.metadata.date"];
}

- (NSDate *)maxDate {
    return [self.photos valueForKeyPath:@"@max.metadata.date"];
}

- (NSProgress *)progress {
    return [[NSProgress alloc] init];
}

- (NSString *)reportState {
    return @"Published";
}

- (UIColor *)reportStateColor {
    return [UIColor blackColor];
}

- (NSString *)uploadState {
    return @"Uploaded";
}

- (BOOL)showProgressBars {
    return NO;
}

- (BOOL)hasPrefilledEmail {
    return NO;
}

- (ReportDraft *)draft {
    return nil;
}

@end
