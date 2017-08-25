//
//  ReportHeaderView.m
//  Amal
//
//  Created by Soroush Khanlou on 8/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportHeaderView.h"
#import "CGGeometry.h"

@interface ReportHeaderView ()

@property (nonatomic) MKMapView *mapView;

@property (nonatomic) UIView *containerView;

@property (nonatomic) UITextField *titleField;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *countLabel;
@property (nonatomic) UILabel *countDescriptionLabel;

@end

@implementation ReportHeaderView

- (MKMapView *)mapView {
    if (!_mapView) {
        MKMapView *mapView = [[MKMapView alloc] init];
        [self addSubview:mapView];
        self.mapView = mapView;
    }
    return _mapView;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc] init];
        containerView.backgroundColor  = [UIColor whiteColor];
        containerView.layer.cornerRadius = 5;
        containerView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.3].CGColor;
        containerView.layer.shadowOffset = CGSizeMake(0, 0);
        containerView.layer.shadowRadius = 4;
        containerView.layer.shadowOpacity = 1;
        [self addSubview:containerView];
        self.containerView = containerView;
    }
    return _containerView;
}

- (UITextField *)titleField {
    if (!_titleField) {
        UITextField *titleField = [[UITextField alloc] init];
        titleField.font = [UIFont boldSystemFontOfSize:26];
        titleField.placeholder = @"Title";
        [self addSubview:titleField];
        self.titleField = titleField;
    }
    return _titleField;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect workingRect = self.bounds;

    CGRect mapRect = CGRectZero;
    mapRect = workingRect;
    mapRect.size.height = 100;

    CGRect containerRect = CGRectZero, titleRect = CGRectZero;
    workingRect = CGRectInset(workingRect, 10, 10);
    workingRect = CGRectTrim(workingRect, 30, CGRectMinYEdge);

    containerRect = workingRect;

    workingRect = CGRectInset(workingRect, 15, 15);
    CGRectDivide(workingRect, &titleRect, &workingRect, 30, CGRectMinYEdge);

    self.mapView.frame = mapRect;
    self.containerView.frame = containerRect;
    self.titleField.frame = titleRect;
}


@end
