//
//  CaptureNotesViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureNotesView.h"

@class LocalPhoto;

@interface CaptureNotesViewController : UIViewController

@property (nonatomic) CaptureNotesView *view;

@property (nonatomic, readonly) LocalPhoto *photo;

- (instancetype)initWithPhoto:(LocalPhoto *)localPhoto;

@end

