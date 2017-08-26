//
//  ReportHeaderView.m
//  Amal
//
//  Created by Soroush Khanlou on 8/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportHeaderView.h"
#import "CGGeometry.h"
#import "UIColor+Additions.h"

@interface ReportHeaderView ()

@property (nonatomic) MKMapView *mapView;

@property (nonatomic) UIView *containerView;

@property (nonatomic) UITextField *titleField;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *countLabel;
@property (nonatomic) UIView *separator;
@property (nonatomic) UILabel *uploadStateLabel;
@property (nonatomic) UIProgressView *totalProgressView;
@property (nonatomic) UILabel *creationDateLabel;
@property (nonatomic) UILabel *reportStateLabel;

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
        titleField.font = [UIFont boldSystemFontOfSize:28.0];
        titleField.placeholder = @"Title";
        [self.containerView addSubview:titleField];
        self.titleField = titleField;
    }
    return _titleField;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
        dateLabel.font = [UIFont fontWithName:@".SFUIDisplay-Semibold" size:16.0];
        [self.containerView addSubview:dateLabel];
        self.dateLabel = dateLabel;
    }
    return _dateLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.textColor = [UIColor colorWithHex:0xaaaaaa];
        countLabel.font = [UIFont fontWithName:@".SFUIDisplay-Semibold" size:16.0];
        [self.containerView addSubview:countLabel];
        self.countLabel = countLabel;
    }
    return _countLabel;
}

- (UIView *)separator {
    if (!_separator) {
        UIView *separator = [[UIView alloc] init];
        separator.backgroundColor  = [UIColor colorWithHex:0xC7C7CC];
        [self.containerView addSubview:separator];
        self.separator = separator;
    }
    return _separator;
}

- (UILabel *)uploadStateLabel {
    if (!_uploadStateLabel) {
        UILabel *uploadStateLabel = [[UILabel alloc] init];
        uploadStateLabel.textColor = [UIColor colorWithHex:0x4A4A4A];
        uploadStateLabel.font = [UIFont fontWithName:@".SFUIDisplay-Regular" size:20.0];
        uploadStateLabel.textAlignment = NSTextAlignmentCenter;
        [self.containerView addSubview:uploadStateLabel];
        self.uploadStateLabel = uploadStateLabel;
    }
    return _uploadStateLabel;
}

- (UIProgressView *)totalProgressView {
    if (!_totalProgressView) {
        UIProgressView *totalProgressView = [[UIProgressView alloc] init];
        [self.containerView addSubview:totalProgressView];
        self.totalProgressView = totalProgressView;
    }
    return _totalProgressView;
}

- (UILabel *)creationDateLabel {
    if (!_creationDateLabel) {
        UILabel *creationDateLabel = [[UILabel alloc] init];
        creationDateLabel.textColor = [UIColor colorWithHex:0x4A4A4A];
        creationDateLabel.font = [UIFont fontWithName:@".SFUIDisplay-Semibold" size:14.0];
        [self.containerView addSubview:creationDateLabel];
        self.creationDateLabel = creationDateLabel;
    }
    return _creationDateLabel;
}

- (UILabel *)reportStateLabel {
    if (!_reportStateLabel) {
        UILabel *reportStateLabel = [[UILabel alloc] init];
        reportStateLabel.textColor = [UIColor colorWithHex:0x4A4A4A];
        reportStateLabel.font = [UIFont fontWithName:@".SFUIDisplay-Semibold" size:14.0];
        reportStateLabel.textAlignment = NSTextAlignmentRight;
        [self.containerView addSubview:reportStateLabel];
        self.reportStateLabel = reportStateLabel;
    }
    return _reportStateLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self sendSubviewToBack:self.mapView];

    CGRect workingRect = self.bounds;

    CGRect mapRect = CGRectZero;
    mapRect = workingRect;
    mapRect.size.height = 100;

    CGRect containerRect = CGRectZero, titleRect = CGRectZero, dateRect = CGRectZero, countRect = CGRectZero, separatorRect = CGRectZero, uploadStateRect = CGRectZero, totalProgressRect = CGRectZero, creationDateRect = CGRectZero, reportStateRect = CGRectZero;
    workingRect = CGRectInset(workingRect, 10, 25);
    workingRect = CGRectTrim(workingRect, 30, CGRectMinYEdge);

    containerRect = workingRect;

    workingRect.origin = CGPointZero;

    workingRect = CGRectInset(workingRect, 15, 15);

    CGRectDivide(workingRect, &titleRect, &workingRect, 40, CGRectMinYEdge);
    CGRectDivide(workingRect, &dateRect, &workingRect, 26, CGRectMinYEdge);
    CGRectDivide(workingRect, &countRect, &workingRect, 26, CGRectMinYEdge);
    workingRect = CGRectTrim(workingRect, 10, CGRectMinYEdge);
    CGRectDivide(workingRect, &separatorRect, &workingRect, 1, CGRectMinYEdge);
    workingRect = CGRectTrim(workingRect, 10, CGRectMinYEdge);
    CGRectDivide(workingRect, &uploadStateRect, &workingRect, 40, CGRectMinYEdge);
    CGRectDivide(workingRect, &totalProgressRect, &workingRect, 2, CGRectMinYEdge);
    workingRect = CGRectTrim(workingRect, 15, CGRectMinYEdge);
    CGRectDivide(workingRect, &creationDateRect, &reportStateRect, workingRect.size.width/2, CGRectMinXEdge);

    self.mapView.frame = mapRect;
    self.containerView.frame = containerRect;
    self.titleField.frame = titleRect;
    self.dateLabel.frame = dateRect;
    self.countLabel.frame = countRect;
    self.separator.frame = separatorRect;
    self.uploadStateLabel.frame = uploadStateRect;
    self.totalProgressView.frame = totalProgressRect;
    self.creationDateLabel.frame = creationDateRect;
    self.reportStateLabel.frame = reportStateRect;
}

@end
