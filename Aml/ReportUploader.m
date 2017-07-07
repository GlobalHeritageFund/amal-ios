//
//  ReportUploader.m
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportUploader.h"
#import "Firebase.h"
#import "Report.h"
#import "LocalPhoto.h"
#import "AMLMetadata.h"

@implementation ReportUploader

- (FIRDatabase *)database {
    return [FIRDatabase database];
}

- (void)upload:(Report *)report completion:(void (^)())completion {
    dispatch_group_t group = dispatch_group_create();

    FIRDatabaseReference *ref = [[[self database] reference] child:@"reports"];

    ref = [ref childByAutoId];

    ref = [ref child:@"images"];

    for (LocalPhoto *photo in report.photos) {
        dispatch_group_enter(group);
        [self uploadPhoto:photo atRef:[ref childByAutoId] completion:^{
            dispatch_group_leave(group);
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completion();
    });
}

- (void)uploadPhoto:(LocalPhoto *)photo atRef:(FIRDatabaseReference *)ref completion:(void (^)())completion {

    dispatch_group_t group = dispatch_group_create();

    dispatch_group_enter(group);
    [[ref child:@"settings"] setValue:photo.metadata.dictionaryRepresentation withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(error) {
            NSLog(@"Image metadata error was: %@", error);
        } else {
            dispatch_group_leave(group);
        }
    }];

    dispatch_group_enter(group);
    FIRStorageReference *imageRef = [[[[FIRStorage storage] reference] child:@"images"] child:ref.key];
    [[ref child:@"imageRef"] setValue:imageRef.fullPath withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
        if(error) {
            NSLog(@"imageRef error was: %@", error);
        } else {
            dispatch_group_leave(group);
        }
    }];

    FIRStorageMetadata *metadata = [FIRStorageMetadata new];

    metadata.contentType = @"image/jpeg";

    dispatch_group_enter(group);

    [photo loadFullSize:^(UIImage *image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        [imageRef putData:imageData metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
            if(error) {
                NSLog(@"Image upload error was: %@", error);
            } else {
                dispatch_group_leave(group);
            }
        }];
    }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completion();
    });
}

@end
