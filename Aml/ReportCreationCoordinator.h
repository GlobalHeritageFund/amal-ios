//
//  ReportCreationCoordinator.h
//  Amal
//
//  Created by Soroush Khanlou on 8/12/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportCreationCoordinator : NSObject

@property (nonatomic, readonly) UIViewController *viewController;

- (instancetype)initWithViewController:(UIViewController *)viewController;

- (void)start;

@end
