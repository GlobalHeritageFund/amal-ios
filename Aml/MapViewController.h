//
//  MapViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 6/30/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ReportProtocols.h"

@interface MapViewController : UIViewController

- (instancetype)initWithPhotos:(NSArray<id<PhotoProtocol>> *)photos;

@property (nonatomic) MKMapView *mapView;

@end
