//
//  CaptureCoordinator.h
//  Amal
//
//  Created by Soroush Khanlou on 12/14/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptureCoordinator : NSObject

@property (readonly) UINavigationController *navigationController;

- (void)start;

@end
