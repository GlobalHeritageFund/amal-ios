//
//  HerBridgePhoto.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/27/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportProtocols.h"

@interface HerBridgePhoto : NSObject <PhotoProtocol>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
