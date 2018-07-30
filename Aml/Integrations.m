//
//  Integrations.m
//  Amal
//
//  Created by Soroush Khanlou on 7/20/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

@import FirebaseDatabase;
@import Firebase;
#import "Integrations.h"
#import <Crashlytics/Crashlytics.h>

@implementation CrashlyticsIntegration

- (void)setUp {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Secrets" ofType:@"plist" inDirectory:nil forLocalization:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:nil];

    [Crashlytics startWithAPIKey:dictionary[@"crashlyticsKey"]];
}

@end


@implementation FirebaseIntegration

- (void)setUp {
    [FIRApp configure];

    [[FIRConfiguration sharedInstance] setLoggerLevel:FIRLoggerLevelMin];

    [FIRDatabase database].persistenceEnabled = YES;
}

@end
