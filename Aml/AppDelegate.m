//
//  AppDelegate.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Firebase.h"
#import "AppCoordinator.h"

@interface AppDelegate ()

@property (nonatomic) AppCoordinator *coordinator;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Secrets" ofType:@"plist" inDirectory:nil forLocalization:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:nil];

    [Crashlytics startWithAPIKey:dictionary[@"crashlyticsKey"]];

    [FIRApp configure];

    [[FIRConfiguration sharedInstance] setLoggerLevel:FIRLoggerLevelMin];
    
    [FIRDatabase database].persistenceEnabled = YES;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

    self.window = [[UIWindow alloc] init];
    self.coordinator = [[AppCoordinator alloc] initWithWindow:self.window];
    [self.coordinator start];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


@end
