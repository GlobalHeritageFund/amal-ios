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
#import "CurrentUser.h"
#import "DatabasePicker.h"

@interface ReportHeaderView ()

@property (nonatomic) MKMapView *mapView;

@property (nonatomic) UIView *containerView;

@property (nonatomic) UITextField *titleField;
@property (nonatomic) UITextField *assessorEmailField;

@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *countLabel;
@property (nonatomic) UIButton *uploadStateButton;
@property (nonatomic) UIProgressView *totalProgressView;
@property (nonatomic) UILabel *creationDateLabel;
@property (nonatomic) UILabel *reportStateLabel;

@property (nonatomic) DatabasePicker *databasePicker;

@end

@implementation ReportHeaderView

- (MKMapView *)mapView {
    if (!_mapView) {
        MKMapView *mapView = [[MKMapView alloc] init];
        mapView.zoomEnabled = NO;
        mapView.scrollEnabled = NO;
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

- (UITextField *)assessorEmailField {
    if (!_assessorEmailField) {
        UITextField *assessorEmailField = [[UITextField alloc] init];
        assessorEmailField.font = [UIFont boldSystemFontOfSize:20.0];
        assessorEmailField.placeholder = @"Email";
        assessorEmailField.keyboardType = UIKeyboardTypeEmailAddress;
        assessorEmailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self.containerView addSubview:assessorEmailField];
        self.assessorEmailField = assessorEmailField;
    }
    return _assessorEmailField;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = [UIColor colorWithHex:0x666666];
        dateLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
        [self.containerView addSubview:dateLabel];
        self.dateLabel = dateLabel;
    }
    return _dateLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        UILabel *countLabel = [[UILabel alloc] init];
        countLabel.textColor = [UIColor colorWithHex:0x666666];
        countLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
        [self.containerView addSubview:countLabel];
        self.countLabel = countLabel;
    }
    return _countLabel;
}

- (DatabasePicker *)databasePicker {
    if (!_databasePicker) {
        DatabasePicker *databasePicker = [[DatabasePicker alloc] init];

        [databasePicker addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];

        [self.containerView addSubview:databasePicker];
        self.databasePicker = databasePicker;
    }
    return _databasePicker;
}

- (UIButton *)uploadStateButton {
    if (!_uploadStateButton) {
        UIButton *uploadStateButton = [[UIButton alloc] init];
        [uploadStateButton setTitleColor:[UIColor colorWithHex:0x4A4A4A] forState:UIControlStateDisabled];
        [uploadStateButton setTitleColor:[UIColor amalTeal] forState:UIControlStateNormal];
        uploadStateButton.titleLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightSemibold];
        uploadStateButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.containerView addSubview:uploadStateButton];
        self.uploadStateButton = uploadStateButton;
    }
    return _uploadStateButton;
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
        creationDateLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
        [self.containerView addSubview:creationDateLabel];
        self.creationDateLabel = creationDateLabel;
    }
    return _creationDateLabel;
}

- (UILabel *)reportStateLabel {
    if (!_reportStateLabel) {
        UILabel *reportStateLabel = [[UILabel alloc] init];
        reportStateLabel.textColor = [UIColor colorWithHex:0x4A4A4A];
        reportStateLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightSemibold];
        reportStateLabel.textAlignment = NSTextAlignmentRight;
        [self.containerView addSubview:reportStateLabel];
        self.reportStateLabel = reportStateLabel;
    }
    return _reportStateLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self sendSubviewToBack:self.mapView];

    BOOL shouldShowSwitcher = ([CurrentUser shared].unlockedDatabaseTargets.count > 1) && self.enabled;

    CGRect workingRect = self.bounds;

    CGRect mapRect = CGRectZero;
    mapRect = workingRect;
    mapRect.size.height = 100;

    CGRect containerRect = CGRectZero, titleRect = CGRectZero, assessorEmailRect = CGRectZero, dateRect = CGRectZero, countRect = CGRectZero, uploadStateRect = CGRectZero, totalProgressRect = CGRectZero, creationDateRect = CGRectZero, reportStateRect = CGRectZero, databasePickerRect = CGRectZero;
    workingRect = CGRectInset(workingRect, 10, 25);
    workingRect = CGRectTrim(workingRect, 30, CGRectMinYEdge);

    containerRect = workingRect;

    workingRect.origin = CGPointZero;

    workingRect = CGRectInset(workingRect, 15, 15);

    CGRectDivide(workingRect, &titleRect, &workingRect, 40, CGRectMinYEdge);
    CGRectDivide(workingRect, &assessorEmailRect, &workingRect, 24, CGRectMinYEdge);
    CGRectDivide(workingRect, &dateRect, &workingRect, 26, CGRectMinYEdge);
    CGRectDivide(workingRect, &countRect, &workingRect, 26, CGRectMinYEdge);
    workingRect = CGRectTrim(workingRect, 10, CGRectMinYEdge);
    
    if (shouldShowSwitcher) {
        CGRectDivide(workingRect, &databasePickerRect, &workingRect, 40, CGRectMinYEdge);
        workingRect = CGRectTrim(workingRect, 10, CGRectMinYEdge);
    }
    
    CGRectDivide(workingRect, &uploadStateRect, &workingRect, 40, CGRectMinYEdge);
    
    workingRect = CGRectTrim(workingRect, 10, CGRectMinYEdge);
    CGRectDivide(workingRect, &totalProgressRect, &workingRect, 2, CGRectMinYEdge);
    workingRect = CGRectTrim(workingRect, 15, CGRectMinYEdge);

    CGSize dateSize = [self.creationDateLabel sizeThatFits:workingRect.size];
    CGRectDivide(workingRect, &creationDateRect, &reportStateRect, dateSize.width, CGRectMinXEdge);

    self.mapView.frame = mapRect;
    self.containerView.frame = containerRect;
    self.titleField.frame = titleRect;
    self.assessorEmailField.frame = assessorEmailRect;
    self.dateLabel.frame = dateRect;
    self.countLabel.frame = countRect;
    self.uploadStateButton.frame = uploadStateRect;
    self.totalProgressView.frame = totalProgressRect;
    self.creationDateLabel.frame = creationDateRect;
    self.reportStateLabel.frame = reportStateRect;
    
    if (shouldShowSwitcher) {
        self.databasePicker.frame = databasePickerRect;
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if (self.enabled) {
        [self.delegate reportHeaderViewTappedDatabasePicker:self];
    }
}

- (BOOL)enabled {
    return self.titleField.enabled;
}

- (void)setEnabled:(BOOL)enabled {
    self.titleField.enabled = enabled;
    self.assessorEmailField.enabled = enabled;
    self.databasePicker.enabled = enabled;
}

@end
