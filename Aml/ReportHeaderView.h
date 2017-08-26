//
//  ReportHeaderView.h
//  Amal
//
//  Created by Soroush Khanlou on 8/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ReportHeaderView : UIView

@property (readonly) UITextField *titleField;
@property (readonly) UILabel *dateLabel;
@property (readonly) UILabel *countLabel;
@property (readonly) UILabel *uploadStateLabel;
@property (readonly) UIProgressView *totalProgressView;
@property (readonly) UILabel *creationDateLabel;
@property (readonly) UILabel *reportStateLabel;

@end
