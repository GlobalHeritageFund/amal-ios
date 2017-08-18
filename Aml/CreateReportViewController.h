//
//  CreateReportViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReportDraft, ReportUpload, LocalPhoto, CreateReportViewController;

@protocol CreateReportViewControllerDelegate <NSObject>

- (void)createReportViewController:(CreateReportViewController *)createReportViewController didTapUploadWithDraft:(ReportDraft *)draft;

- (void)createReportViewController:(CreateReportViewController *)createReportViewController didSelectPhoto:(LocalPhoto *)photo;

@end

@interface CreateReportViewController : UIViewController

@property (nonatomic, weak) id<CreateReportViewControllerDelegate> delegate;

@property (nonatomic) UITableView *view;

- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft;

@property (nonatomic) ReportDraft *reportDraft;

@property (nonatomic) ReportUpload *upload;

@property (nonatomic) UIBarButtonItem *uploadButton;

@end
