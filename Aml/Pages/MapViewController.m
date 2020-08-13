//
//  MapViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/30/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "MapViewController.h"
#import "AMLMetadata.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (instancetype)initWithPhotos:(NSArray<id<PhotoProtocol>> *)photos {
    self = [super init];
    if (!self) return nil;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(photos.firstObject.metadata.coordinate, 1500, 1500);
    [self.mapView setRegion:viewRegion animated:NO];

    for (id<PhotoProtocol> photo in photos) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:photo.metadata.coordinate];
        [annotation setTitle:photo.metadata.name];
        [self.mapView addAnnotation:annotation];
    }

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
