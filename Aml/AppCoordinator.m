//
//  AppCoordinator.m
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "AppCoordinator.h"
#import "UIColor+Additions.h"
#import "TabBarPage.h"
#import "FirstLaunch.h"
#import "AssessCoordinator.h"
#import "CaptureCoordinator.h"
#import "ReportCoordinator.h"

@interface AppCoordinator () 

@property (nonatomic) FirstLaunch *firstLaunch;
@property (nonatomic) NSMutableArray *childCoordinators;

@end

@implementation AppCoordinator

- (instancetype)initWithWindow:(UIWindow *)window {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.window = window;
    return self;
}

- (NSMutableArray *)childCoordinators {
    if (!_childCoordinators) {
        self.childCoordinators = [NSMutableArray array];
    }
    return _childCoordinators;
}

- (FirstLaunch *)firstLaunch {
    if (!_firstLaunch) {
        _firstLaunch = [FirstLaunch new];
    }
    return _firstLaunch;
}

- (void)start {
    TabBarPage *tabBarController = [TabBarPage new];

    AssessCoordinator *assessCoordinator = [[AssessCoordinator alloc] init];
    [assessCoordinator start];
    [self.childCoordinators addObject:assessCoordinator];


    CaptureCoordinator *captureCoordinator = [[CaptureCoordinator alloc] init];
    [captureCoordinator start];
    [self.childCoordinators addObject:captureCoordinator];


    ReportCoordinator *reportCoordinator = [[ReportCoordinator alloc] init];
    [reportCoordinator start];
    [self.childCoordinators addObject:reportCoordinator];


    tabBarController.viewControllers = @[
                                         assessCoordinator.navigationController,
                                         captureCoordinator.navigationController,
                                         reportCoordinator.navigationController,
                                         ];

    tabBarController.selectedIndex = 1;
    self.window.tintColor = [UIColor amalTeal];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];

    if (self.firstLaunch.isFirstLaunch) {
        UIViewController *page = [[UIStoryboard storyboardWithName:@"Intro" bundle:nil] instantiateInitialViewController];

        [self.window.rootViewController presentViewController:page animated:YES completion:nil];

        [self.firstLaunch launched];
    }
    
    [self setupGlobalAppearances];
}

- (void)setupGlobalAppearances {
    [[UISwitch appearance] setOnTintColor:[UIColor amalTeal]];
}

@end
