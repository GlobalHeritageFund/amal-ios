//
//  EditLocationViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 12/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "EditLocationViewController.h"
#import "CGGeometry.h"
#import "UIColor+Additions.h"
#import "UIImage+Additions.h"

@interface EditLocationViewController () <MKMapViewDelegate>

@property (nonatomic) BOOL mapMoved;

@end

@implementation EditLocationViewController

- (instancetype)initWithLocation:(CLLocationCoordinate2D)location {
    self = [super init];
    if (!self) return nil;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 1500, 1500);
    [self.mapView setRegion:viewRegion animated:NO];
    self.mapMoved = NO;

    return self;
}

- (instancetype)initGlobally {
    self = [super init];
    if (!self) return nil;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(0, 0), 10000000, 10000000);
    [self.mapView setRegion:viewRegion animated:NO];
    self.mapMoved = NO;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Edit Location";
}

- (MKMapView *)mapView {
    if (!_mapView) {
        MKMapView *mapView = [[MKMapView alloc] init];
        mapView.delegate = self;
        mapView.rotateEnabled = NO;
        [self.view addSubview:mapView];
        self.mapView = mapView;
    }
    return _mapView;
}

- (UIButton *)updateButton {
    if (!_updateButton) {
        UIButton *updateButton = [[UIButton alloc] init];
        [updateButton setTitle:@"Update Location" forState:UIControlStateNormal];
        [updateButton setBackgroundImage:[UIImage imageWithColor:[UIColor amalTeal]] forState:UIControlStateNormal];
        [updateButton setBackgroundImage:[UIImage imageWithColor:[[UIColor amalTeal] colorWithAlphaComponent:0.5]] forState:UIControlStateDisabled];
        updateButton.enabled = NO;
        updateButton.layer.cornerRadius = 6.0f;
        updateButton.clipsToBounds = YES;
        [updateButton addTarget:self action:@selector(updateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:updateButton];
        self.updateButton = updateButton;
    }
    return _updateButton;
}

- (UIImageView *)pinImage {
    if (!_pinImage) {
        UIImageView *pinImage = [[UIImageView alloc] init];
        pinImage.backgroundColor = [UIColor redColor];
        [self.view addSubview:pinImage];
        self.pinImage = pinImage;
    }
    return _pinImage;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.mapMoved = YES;
}

- (void)setMapMoved:(BOOL)mapMoved {
    _mapMoved = mapMoved;
    _updateButton.enabled = mapMoved;
}

- (void)updateButtonTapped:(UIButton *)sender {
    [self.delegate editLocationViewControllerUpdateLocationButtonTapped:self];
}

- (void)resetUpdateButton {
    self.mapMoved = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.mapView.frame = self.view.bounds;

    [self.pinImage sizeToFit];
    self.pinImage.frame = CGRectMake(0, 0, 20, 20);
    self.pinImage.center = self.view.center;

    CGRect workingRect = self.view.bounds;

    CGRect updateButtonRect = CGRectZero;

    workingRect = CGRectInsetToSize(workingRect, CGSizeMake(200, 44));

    updateButtonRect = CGRectOffset(workingRect, 0, 200);

    self.updateButton.frame = updateButtonRect;
}

@end
