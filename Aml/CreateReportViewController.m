//
//  CreateReportViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "CreateReportViewController.h"

@interface CreateReportViewController ()

@end

@implementation CreateReportViewController

- (instancetype)initWithReport:(Report *)report {
    self = [super init];
    if (!self) return nil;

    _report = report;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Create Report";
}

@end
