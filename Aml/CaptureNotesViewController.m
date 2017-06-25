//
//  CaptureNotesViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "CaptureNotesViewController.h"
#import "LocalPhoto.h"

@interface CaptureNotesViewController ()

@property (nonatomic) UIStackView *stackView;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) LocalPhoto *photo;
@end

@implementation CaptureNotesViewController

- (UIStackView *)stackView {
    if (!_stackView) {
        UIStackView *stackView = [[UIStackView alloc] init];
        [self.scrollView addSubview:stackView];
        self.stackView = stackView;
    }
    return _stackView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.alwaysBounceVertical = true;
        scrollView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:scrollView];
        self.scrollView = scrollView;
    }
    return _scrollView;
}

- (instancetype)initWithPhoto:(LocalPhoto *)photo {
    self = [super init];
    if (!self) {
        return nil;
    }
    _photo = photo;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Capture Notes";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteTapped:)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.stackView.intrinsicContentSize.height);
}

- (void)deleteTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"Are you sure you want to delete this photo? This can not be undone." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [self.photo unsync];
        [self.photo removeLocalData];
        [self.navigationController popViewControllerAnimated:true];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:true completion:nil];
}


@end
