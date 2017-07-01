//
//  MapViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 6/30/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@property (nonatomic) MKMapView *mapView;

@end
