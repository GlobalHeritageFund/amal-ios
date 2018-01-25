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

@property (readonly) MKMapView *mapView;
@property (readonly) UITextField *titleField;
@property (readonly) UITextField *assessorEmailField;
@property (readonly) UILabel *dateLabel;
@property (readonly) UILabel *countLabel;
@property (readonly) UIButton *uploadStateButton;
@property (readonly) UIProgressView *totalProgressView;
@property (readonly) UILabel *creationDateLabel;
@property (readonly) UILabel *reportStateLabel;

@property BOOL enabled;

@end
