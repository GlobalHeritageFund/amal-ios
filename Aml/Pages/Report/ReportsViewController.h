//
//  ReportsViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 7/31/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReportsViewController, FirebaseReport, ReportDraft, FirebaseReportDataSource, LocalDraftDataSource;

@protocol ReportsViewControllerDelegate <NSObject>

- (void)reportsViewControllerDidTapCompose:(ReportsViewController *)reportsViewController;
- (void)reportsViewController:(ReportsViewController *)reportsViewController didTapReport:(FirebaseReport *)report;
- (void)reportsViewController:(ReportsViewController *)reportsViewController didTapDraft:(ReportDraft *)reportDraft;
- (void)reportsViewController:(ReportsViewController *)reportsViewController shouldDeleteDraft:(ReportDraft *)reportDraft atIndexPath:(NSIndexPath *)indexPath;
- (void)reportsViewController:(ReportsViewController *)reportsViewController shouldDeleteReport:(FirebaseReport *)report atIndexPath:(NSIndexPath *)indexPath;

@end

@interface ReportsViewController : UIViewController

@property (nonatomic, weak) id<ReportsViewControllerDelegate> delegate;

@property (readonly) FirebaseReportDataSource *publishedReports;
@property (readonly) LocalDraftDataSource *localDrafts;
@property (nonatomic) UITableView *tableView;

@end
