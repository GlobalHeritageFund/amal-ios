//
//  MapViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/30/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (!self) return nil;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 1500, 1500);
    [self.mapView setRegion:viewRegion animated:NO];

    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    [annotation setTitle:@"Photo"];
    [self.mapView addAnnotation:annotation];

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Map";
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
