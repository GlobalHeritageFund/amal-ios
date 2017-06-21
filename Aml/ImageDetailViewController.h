//
//  ImageDetailViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageDetailViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIScrollView *scrollView;

@end
