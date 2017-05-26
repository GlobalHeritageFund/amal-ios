//
//  AssessPage.m
//  Amal
//
//  Created by Dustin Dettmer on 4/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "AssessPage.h"
#import "PhotoSettings.h"
#import "LocalPhoto.h"
#import "CaptureNotesPage.h"
#import <objc/runtime.h>

static const void *localPhotoKey = &localPhotoKey;

@interface AssessPage ()

@property (strong) NSArray<LocalPhoto*> *localImages;

@end

@implementation AssessPage

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.localImages = PhotoSettings.shared.localPhotos;
    
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.localImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *imageView = (id)[cell viewWithTag:1];
    
    LocalPhoto *localPhoto = self.localImages[indexPath.row];
    
    objc_setAssociatedObject(cell, localPhotoKey, localPhoto, OBJC_ASSOCIATION_ASSIGN);
    
    if(localPhoto.image)
        imageView.image = localPhoto.image;
    else {
        
        [localPhoto load:^(LocalPhoto *localPhoto) {
            
            if(objc_getAssociatedObject(cell, localPhotoKey) != localPhoto)
                return;
            
            UIImageView *imageView = (id)[cell viewWithTag:1];
            
            imageView.image = localPhoto.image;
        }];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat v = (self.view.bounds.size.width - 8 * 2) / 4 - 5;
    
    return CGSizeMake(v, v);
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqual:@"imageTap"]) {
        
        return [objc_getAssociatedObject(sender, localPhotoKey) image] != nil;
    }
    
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqual:@"imageTap"]) {
        
        CaptureNotesPage *page = segue.destinationViewController;
        
        page.localPhoto = objc_getAssociatedObject(sender, localPhotoKey);
    }
}

@end
