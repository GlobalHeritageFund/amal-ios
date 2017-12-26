//
//  EditLocationViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 12/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface EditLocationViewController : UIViewController

- (instancetype)initWithLocation:(CLLocationCoordinate2D)location;

- (instancetype)initGlobally;

@property (nonatomic) MKMapView *mapView;

@end
