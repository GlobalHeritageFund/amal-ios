//
//  CaptureNotesViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocalPhoto;

@interface CaptureNotesViewController : UIViewController

@property (nonatomic, readonly) LocalPhoto *photo;

- (instancetype)initWithPhoto:(LocalPhoto *)localPhoto;

@end
