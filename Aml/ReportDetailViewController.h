//
//  ReportDetailViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReportDraft, ReportUpload, LocalPhoto, ReportDetailViewController, ReportViewModel;

@protocol ReportDetailViewControllerDelegate <NSObject>

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didTapUploadWithDraft:(ReportDraft *)draft;
- (void)reportDetailViewControllerDidTapCancel:(ReportDetailViewController *)reportDetailViewController;

- (void)reportDetailViewController:(ReportDetailViewController *)reportDetailViewController didSelectPhoto:(LocalPhoto *)photo;
- (void)reportDetailViewControllerDidTapAddPhoto:(ReportDetailViewController *)reportDetailViewController;

@end

@interface ReportDetailViewController : UIViewController

@property (nonatomic, weak) id<ReportDetailViewControllerDelegate> delegate;

@property (nonatomic) UITableView *view;

@property (nonatomic, readonly) UITableView *tableView;


- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft;
- (instancetype)initWithReportViewModel:(ReportViewModel *)viewModel;

@property (nonatomic) ReportViewModel *viewModel;

@property (nonatomic) UIBarButtonItem *uploadButton;

- (void)updateUploadButtonState;

@end
