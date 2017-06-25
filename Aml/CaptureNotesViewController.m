//
//  CaptureNotesViewController.m
//  Amal
//
//  Created by Soroush Khanlou on 6/25/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "CaptureNotesViewController.h"
#import "LocalPhoto.h"
#import "NotesForm.h"

@interface CaptureNotesViewController ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) LocalPhoto *photo;
@property (nonatomic) NSMutableArray *formGroups;

@end

@implementation CaptureNotesViewController

- (instancetype)initWithPhoto:(LocalPhoto *)photo {
    self = [super init];
    if (!self) {
        return nil;
    }
    _photo = photo;
    return self;
}

- (NSMutableArray *)formGroups {
    if (!_formGroups) {
        _formGroups = [@[] mutableCopy];
    }
    return _formGroups;
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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Capture Notes";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteTapped:)];

    PhotoFormElement *photo = [[PhotoFormElement alloc] init];
    photo.imageView.image = self.photo.image;
    FormGroup *group = [[FormGroup alloc] init];
    [group updateHeaderText: @"Photo"];
    [group addFormElement:photo];
    [self.scrollView addSubview:group];
    [self.formGroups addObject:group];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, [[self.formGroups valueForKeyPath:@"@sum.expectedHeight"] floatValue]);
    CGRect workingRect = self.view.bounds;
    workingRect.size.height = self.scrollView.contentSize.height;
    for (FormGroup *group in self.formGroups) {
        CGRect groupRect = CGRectZero;
        CGRectDivide(workingRect, &groupRect, &workingRect, group.expectedHeight, CGRectMinYEdge);
        group.frame = groupRect;
    }
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
