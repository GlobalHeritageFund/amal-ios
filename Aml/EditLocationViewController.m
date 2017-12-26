//
//  EditLocationViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 12/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "EditLocationViewController.h"

@interface EditLocationViewController ()

@end

@implementation EditLocationViewController

- (instancetype)initWithLocation:(CLLocationCoordinate2D)location {
    self = [super init];
    if (!self) return nil;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 1500, 1500);
    [self.mapView setRegion:viewRegion animated:NO];

    return self;
}

- (instancetype)initGlobally {
    self = [super init];
    if (!self) return nil;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(0, 0), 10000000, 10000000);
    [self.mapView setRegion:viewRegion animated:NO];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Edit Location";
}

- (MKMapView *)mapView {
    if (!_mapView) {
        MKMapView *mapView = [[MKMapView alloc] init];
        [self.view addSubview:mapView];
        self.mapView = mapView;
    }
    return _mapView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.mapView.frame = self.view.bounds;
}

@end
