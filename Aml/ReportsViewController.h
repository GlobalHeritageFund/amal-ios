//
//  ReportsViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReportsViewController;

@protocol ReportsViewControllerDelegate <NSObject>

- (void)reportsViewControllerDidTapCompose:(ReportsViewController *)reportsViewController;

@end

@interface ReportsViewController : UITableViewController

@property (nonatomic, weak) id<ReportsViewControllerDelegate> delegate;

@end
