//
//  ImageDetailViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/17/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "ImageDetailViewController.h"

@interface ImageDetailViewController ()

@end

@implementation ImageDetailViewController

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.alwaysBounceVertical = YES;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.maximumZoomScale = 5;
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.clipsToBounds = true;
        [self.view addSubview:scrollView];
        self.scrollView = scrollView;
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:imageView];
        self.imageView = imageView;
    }
    return _imageView;
}

- (BOOL)automaticallyAdjustsScrollViewInsets {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect workingRect = self.view.bounds;

    self.scrollView.frame = workingRect;
    self.scrollView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length], 0, [self.bottomLayoutGuide length], 0);
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake([self.topLayoutGuide length], 0, [self.bottomLayoutGuide length], 0);

    CGSize contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.scrollView.bounds.size.height - [self.topLayoutGuide length] - [self.bottomLayoutGuide length]);
    self.scrollView.contentSize = contentSize;
    
    CGRect imageViewRect = CGRectZero;
    imageViewRect.size = contentSize;
    self.imageView.frame = imageViewRect;
}

@end
