//
//  EditLocationViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 12/26/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class EditLocationViewController;

@protocol EditLocationViewControllerDelegate

- (void)editLocationViewControllerUpdateLocationButtonTapped:(EditLocationViewController *)editLocationViewController;
@end

@interface EditLocationViewController : UIViewController

- (instancetype)initWithLocation:(CLLocationCoordinate2D)location;

- (instancetype)initGlobally;

@property (nonatomic, weak) id<EditLocationViewControllerDelegate> delegate;

@property (nonatomic) MKMapView *mapView;

@property (nonatomic) UIButton *updateButton;

@property (nonatomic) UIImageView *pinImage;

- (void)resetUpdateButton;

@end