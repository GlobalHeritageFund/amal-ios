//
//  CreateReportViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReportDraft;

@interface CreateReportViewController : UIViewController

@property (nonatomic) UITableView *view;

- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft;

@property (nonatomic) ReportDraft *reportDraft;

@end
