//
//  LocalPhotoFilter.m
//  Amal
//
//  Created by Soroush Khanlou on 1/2/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "LocalPhotoFilter.h"
#import "LocalPhoto.h"
#import "AMLMetadata.h"

@implementation DefaultPhotoFilter

- (NSString *)name {
    return @"All";
}

- (BOOL)shouldIncludePhoto:(LocalPhoto *)photo {
    return YES;
}

@end

@implementation UnassessedPhotoFilter

- (NSString *)name {
    return @"Unassessed";
}

- (BOOL)shouldIncludePhoto:(LocalPhoto *)photo {
    AMLMetadata *metadata = photo.metadata;
    return [metadata.notes isEqualToString:@""]
    && metadata.conditionNumber == 0
    && metadata.levelOfDamage == 0
    && [metadata.name isEqualToString:@""];
}

@end

@interface AssessedPhotoFilter ()

@property (nonatomic) UnassessedPhotoFilter *unassessedFilter;

@end

@implementation AssessedPhotoFilter

- (NSString *)name {
    return @"Assessed";
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    _unassessedFilter = [UnassessedPhotoFilter new];

    return self;
}


- (BOOL)shouldIncludePhoto:(LocalPhoto *)photo {
    return ![self.unassessedFilter shouldIncludePhoto:photo];
}

@end

