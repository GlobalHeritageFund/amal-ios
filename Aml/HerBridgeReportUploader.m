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

@end

@implementation HerBridgeReportUploader

- (instancetype)initWithSession:(NSURLSession *)session {
    self = [super init];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)uploadReport:(ReportUpload *)reportUpload {
    
    NSArray *photos = reportUpload.photos;
    
    Promise <NSArray <PhotoUpload *> *> *loadAll = [Promise all:[photos arrayByTransformingObjectsUsingBlock:^id(id <PhotoProtocol> object) {
        return [[object loadFullSizeImage] then:^id _Nullable(UIImage * _Nonnull image) {
            return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(PhotoUpload * _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
                fulfill([[PhotoUpload alloc] initWithImage:image metadata:[object metadata]]);
            }];
        }];
    }]];
    
    Promise *uploadedPhotoPromise = [loadAll then:^id _Nullable(NSArray <PhotoUpload *> * _Nonnull array) {
        return [Promise all:[array arrayByTransformingObjectsUsingBlock:^id(PhotoUpload * image) {
            return [[self.session POSTImageTo:[NSURL URLWithString:@"http://herbridge.legiongis.com/api/image/"] image:image.image metadata:[image.metadata heritageDictionaryRepresentation]] then:^id _Nullable(NSDictionary * _Nonnull dictionary) {
                    return [UploadedPhoto uploadedPhotoFrom:dictionary photoUpload:image];
            }];
        }]];
    }];
    
    [uploadedPhotoPromise then:^id _Nullable(NSArray <UploadedPhoto *> * _Nonnull object) {
        NSLog(@"here %@", object);
        return [Promise all:[object arrayByTransformingObjectsUsingBlock:^id(UploadedPhoto * image) {
            return [[self.session POSTJSONTaskWith:[NSURL URLWithString:@"http://herbridge.legiongis.com/api/resource/"] JSONBody:[image dictionaryRepresentation]] then:^id _Nullable(id  _Nonnull object) {
                NSLog(@"objc %@", object);
                return nil;
            }];
        }]];
    }];
    
    
    
}

@end
