//
//  CreateReportViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Report;

@interface CreateReportViewController : UIViewController

@property (nonatomic) UITableView *view;

- (instancetype)initWithReport:(Report *)report;

@property (nonatomic) Report *report;

@end
