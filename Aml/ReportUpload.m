//
//  ReportUpload.m
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportUpload.h"
#import "Firebase.h"
#import "ReportDraft.h"
#import "LocalPhoto.h"
#import "AMLMetadata.h"
#import "NSArray+Additions.h"
#import "Firebase+Promises.h"
#import "CurrentUser.h"

@interface ReportUpload ()

@property (nonatomic) ReportDraft *reportDraft;

@end

@implementation ReportUpload

- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft {
    self = [super init];
    if (!self) return nil;

    _reportDraft = reportDraft;
    _reportDraft.deviceToken = [CurrentUser shared].deviceToken;
    _promise = [Promise new];
    _progresses = [_reportDraft.photos arrayByTransformingObjectsUsingBlock:^id(id object) {
        NSProgress *progress = [[NSProgress alloc] init];
        progress.totalUnitCount = 100;
        return progress;
    }];

    return self;
}


- (FIRDatabase *)database {
    return [FIRDatabase database];
}

- (FIRDatabaseReference *)reportsDirectory {
    return [[[self database] reference] child:@"reports"];
}

- (FIRStorage *)storage {
    return [FIRStorage storage];
}

- (FIRStorageReference *)imagesDirectory {
    return [[[self storage] reference] child:@"images"];
}

- (void)upload {
    FIRDatabaseReference *reportRef = [self.reportsDirectory childByAutoId];

    NSArray *photoUploadPromises = [self.reportDraft.photos arrayByTransformingObjectsUsingBlock:^id(id photo) {
        FIRDatabaseReference *photoRef = [[reportRef child:@"images"] childByAutoId];
        return [self uploadPhoto:photo atRef:photoRef];
    }];

    [[[Promise all:
             @[
               [[reportRef child:@"title"] promiseSetValue:self.reportDraft.title],
               [[reportRef child:@"authorDeviceToken"] promiseSetValue:self.reportDraft.deviceToken],
               [[reportRef child:@"creationDate"] promiseSetValue:@(self.reportDraft.creationDate.timeIntervalSince1970)],
               [Promise all:photoUploadPromises],
               ]]
            then:^id _Nullable(id  _Nonnull object) {
                [self.promise fulfill:self.reportDraft];
                return nil;
            }] catch:^(NSError * _Nonnull error) {
                [self.promise reject:error];
            }];
}

- (Promise *)uploadPhoto:(LocalPhoto *)photo atRef:(FIRDatabaseReference *)ref {

    NSUInteger index = [self.reportDraft.photos indexOfObject:photo];

    NSProgress *progress = self.progresses[index];

    FIRStorageReference *imageRef = [[self imagesDirectory] child:ref.key];

    FIRStorageMetadata *metadata = [FIRStorageMetadata new];

    metadata.contentType = @"image/jpeg";

    Promise *photoUploadPromise = [[photo loadFullSize] then:^id _Nullable(id  _Nonnull image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        FIRStorageObservableTask *task = [imageRef putData:imageData metadata:metadata];
        [task observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
            progress.completedUnitCount = ((double)progress.totalUnitCount) * snapshot.progress.fractionCompleted;
        }];
        [task observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot * _Nonnull snapshot) {
            progress.completedUnitCount = progress.totalUnitCount;
        }];
        return [task promise];
    }];

    return [Promise all:@[
                          [[ref child:@"settings"] promiseSetValue:photo.metadata.dictionaryRepresentation],
                          [[ref child:@"imageRef"] promiseSetValue:imageRef.fullPath],
                          photoUploadPromise,
                          ]];
}

@end
