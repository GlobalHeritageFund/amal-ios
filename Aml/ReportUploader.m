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
#import "NSArray+Additions.h"
#import "Firebase+Promises.h"

@implementation ReportUploader

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

- (Promise *)upload:(Report *)report {

    FIRDatabaseReference *reportRef = [self.reportsDirectory childByAutoId];

    NSArray *photoUploadPromises = [report.photos arrayByTransformingObjectsUsingBlock:^id(id photo) {
        FIRDatabaseReference *photoRef = [[reportRef child:@"images"] childByAutoId];
        return [self uploadPhoto:photo atRef:photoRef];
    }];

    return [[Promise all:
             @[
               [[reportRef child:@"title"] promiseSetValue:report.title],
               [Promise all:photoUploadPromises],
               ]]
            then:^id _Nullable(id  _Nonnull object) {
                return report;
            }];
}

- (Promise *)uploadPhoto:(LocalPhoto *)photo atRef:(FIRDatabaseReference *)ref {

    FIRStorageReference *imageRef = [[self imagesDirectory] child:ref.key];

    FIRStorageMetadata *metadata = [FIRStorageMetadata new];

    metadata.contentType = @"image/jpeg";

    Promise *photoUploadPromise = [[photo loadFullSize] then:^id _Nullable(id  _Nonnull image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        return [imageRef promisePutData:imageData metadata:metadata];
    }];

    return [Promise all:@[
                          [[ref child:@"settings"] promiseSetValue:photo.metadata.dictionaryRepresentation],
                          [[ref child:@"imageRef"] promiseSetValue:imageRef.fullPath],
                          photoUploadPromise,
                          ]];
}

@end
