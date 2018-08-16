//
//  HerBridgeReportUploader.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "HerBridgeReportUploader.h"
#import "ReportUpload.h"
#import "NSURLSession+Promises.h"
#import "ReportDraft.h"
#import "LocalPhoto.h"
#import "AMLMetadata.h"
#import "NSArray+Additions.h"
#import "UploadedPhoto.h"
#import "PhotoUpload.h"

@interface HerBridgeReportUploader ()

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, readonly) NSArray <NSProgress *> *progresses;

@end

@implementation HerBridgeReportUploader

- (instancetype)initWithSession:(NSURLSession *)session progresses:(NSArray <NSProgress *> *)progresses {
    self = [super init];
    
    if (self) {
        _session = session;
        _progresses = progresses;
    }
    
    return self;
}

- (void)uploadReport:(ReportUpload *)reportUpload {
    
    NSArray *photos = reportUpload.photos;
    
    NSEnumerator <NSProgress *> *progressEnumerator = [self.progresses objectEnumerator];
    
    Promise <NSArray <PhotoUpload *> *> *loadAll = [Promise all:[photos arrayByTransformingObjectsUsingBlock:^id(id <PhotoProtocol> object) {
        NSProgress *progress = [progressEnumerator nextObject];
        return [[object loadFullSizeImage] then:^id _Nullable(UIImage * _Nonnull image) {
            
            Promise *returnPromise = [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(PhotoUpload * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
                fulfill([[PhotoUpload alloc] initWithImage:image metadata:[object metadata]]);
            }];
            
            [returnPromise then:^id _Nullable(id  _Nonnull object) {
                progress.completedUnitCount = progress.totalUnitCount;
                return nil;
            }];
            
            return returnPromise;
        }];
    }]];
    
    Promise *uploadedPhotoPromise = [loadAll then:^id _Nullable(NSArray <PhotoUpload *> * _Nonnull array) {
        return [Promise all:[array arrayByTransformingObjectsUsingBlock:^id(PhotoUpload * image) {
            return [[self.session POSTImageTo:[NSURL URLWithString:@"http://herbridge.legiongis.com/api/image/"] image:image.image metadata:[image.metadata heritageDictionaryRepresentation]] then:^id _Nullable(NSDictionary * _Nonnull dictionary) {
                    return [UploadedPhoto uploadedPhotoFrom:dictionary photoUpload:image];
            }];
        }]];
    }];
    
    Promise * resourcesPromise = [uploadedPhotoPromise then:^id _Nullable(NSArray <UploadedPhoto *> * _Nonnull object) {
        
        NSArray <NSDictionary *> *resources = [object arrayByTransformingObjectsUsingBlock:^id(UploadedPhoto * image) {
            return [image dictionaryRepresentation];
        }];
        
        return [self.session POSTJSONTaskWith:[NSURL URLWithString:@"http://herbridge.legiongis.com/api/report/"] JSONBody:[reportUpload dictionaryRepresentationWithResources:resources]];
    }];
    
    [resourcesPromise then:^id _Nullable(id _Nonnull object) {
        NSLog(@"here %@", object);
        return nil;
    }];
    
    
}

@end
