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
#import "Report.h"

@interface ReportUpload ()

@property (nonatomic) ReportDraft *reportDraft;
@property (nonatomic) NSProgress *totalProgress;

@end

@implementation ReportUpload

- (instancetype)initWithReportDraft:(ReportDraft *)reportDraft {
    self = [super init];
    if (!self) return nil;

    _reportDraft = reportDraft;
    _reportDraft.deviceToken = [CurrentUser shared].deviceToken;
    _promise = [Promise new];
    _totalProgress = [[NSProgress alloc] init];
    _totalProgress.totalUnitCount = 100 * _reportDraft.photos.count;

    _progresses = [_reportDraft.photos arrayByTransformingObjectsUsingBlock:^id(id object) {
        NSProgress *progress = [[NSProgress alloc] init];
        progress.totalUnitCount = 100;
        [_totalProgress addChild:progress withPendingUnitCount:100];
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

    [[[[[Promise all:
         @[
           [[reportRef child:@"title"] promiseSetValue:self.reportDraft.title],
           [[reportRef child:@"authorDeviceToken"] promiseSetValue:self.reportDraft.deviceToken],
           [[reportRef child:@"assessorEmail"] promiseSetValue:self.reportDraft.email],
           [[reportRef child:@"creationDate"] promiseSetValue:@(self.reportDraft.creationDate.timeIntervalSince1970)],
           [Promise all:photoUploadPromises],
           ]]
        then:^id _Nullable(id  _Nonnull object) {
            return [[reportRef child:@"uploadComplete"] promiseSetValue:@YES];
        }]
       then:^id _Nullable(id  _Nonnull object) {
           return [reportRef promiseGet];
       }]
      then:^id _Nullable(id  _Nonnull object) {
          Report *report = [[Report alloc] initWithKey:reportRef.key dictionary:object];
          [self.promise fulfill:report];
          return nil;
      }]
     catch:^(NSError * _Nonnull error) {
         [self.promise reject:error];
     }];
}

- (Promise *)uploadPhoto:(LocalPhoto *)photo atRef:(FIRDatabaseReference *)ref {

    NSUInteger index = [self.reportDraft.photos indexOfObject:photo];

    NSProgress *progress = self.progresses[index];

    FIRStorageReference *imageRef = [[self imagesDirectory] child:ref.key];

    FIRStorageMetadata *metadata = [FIRStorageMetadata new];

    metadata.contentType = @"image/jpeg";

    Promise *photoUploadPromise = [[photo loadFullSizeImage] then:^id _Nullable(id  _Nonnull image) {
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

- (BOOL)isEditable {
    return NO;
}

- (BOOL)hasPrefilledEmail {
    return self.reportDraft.hasPrefilledEmail;
}

- (NSString *)email {
    return self.reportDraft.email;
}

- (NSArray<id<PhotoProtocol>> *)photos {
    return self.reportDraft.photos;
}

- (NSDate *)minDate {
    return self.reportDraft.minDate;
}

- (NSDate *)maxDate {
    return self.reportDraft.maxDate;
}

- (NSString *)title {
    return self.reportDraft.title;
}

- (NSInteger)photoCount {
    return self.reportDraft.photoCount;
}

- (NSDate *)creationDate {
    return self.reportDraft.creationDate;
}

- (NSProgress *)progress {
    return self.totalProgress;
}

- (NSString *)reportState {
    return @"Publishing";
}

- (UIColor *)reportStateColor {
    return [UIColor blackColor];
}

- (NSString *)uploadState {
    return @"Uploading...";
}

- (BOOL)showProgressBars {
    return YES;
}

- (ReportDraft *)draft {
    return self.reportDraft;
}

@end
