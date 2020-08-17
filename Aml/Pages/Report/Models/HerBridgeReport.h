//
//  HerBridgeReport.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/20/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"
#import "ReportProtocols.h"

@interface HerBridgeReport : NSObject <ReportProtocol>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@property (readonly) NSString *title;

@property (readonly) NSString *assessorEmail;

@property (readwrite) DatabaseTarget databaseTarget;

@property (readonly) NSDate *creationDate;

@property (nonatomic, readonly) NSArray< id <PhotoProtocol>> *photos;

@end
