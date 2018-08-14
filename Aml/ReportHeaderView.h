//
//  ReportHeaderView.h
//  Amal
//
//  Created by Soroush Khanlou on 8/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SwitchView.h"

@protocol ReportHeaderViewDelegate

- (void)changedEAMENAStatusTo:(BOOL)status;

@end

@interface ReportHeaderView : UIView

@property (readonly) MKMapView *mapView;
@property (readonly) UITextField *titleField;
@property (readonly) UITextField *assessorEmailField;
@property (readonly) UILabel *dateLabel;
@property (readonly) UILabel *countLabel;
@property (readonly) UIButton *uploadStateButton;
@property (readonly) UIProgressView *totalProgressView;
@property (readonly) UILabel *creationDateLabel;
@property (readonly) UILabel *reportStateLabel;
@property (readonly) SwitchView *switchView;

@property (nonatomic, weak) id <ReportHeaderViewDelegate> delegate;

@property BOOL enabled;

@end
