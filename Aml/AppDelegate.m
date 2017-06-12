//
//  AppDelegate.m
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Firebase.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    [Fabric with:@[[Crashlytics class]]];
    
    [FIRApp configure];
    
    [FIRDatabase database].persistenceEnabled = YES;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}


@end
