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
#import "HerBridgeReport.h"
#import "RequestSender.h"

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

- (NSString *)baseString {
    return @"https://eamena.herbridge.org/";
}

- (NSString *)URLStringWithPath:(NSString *)path {
    return [[self baseString] stringByAppendingString:path];
}

- (Promise *)uploadReport:(ReportUpload *)reportUpload {
    
    RequestSender *factory = [[RequestSender alloc] initWithBaseURLString:[self baseString] session:self.session];
    
    NSArray *photos = reportUpload.photos;
    
    NSEnumerator <NSProgress *> *progressEnumerator = [self.progresses objectEnumerator];
    
    Promise <NSArray <UploadedPhoto *> *> *loadAll = [Promise all:[photos arrayByTransformingObjectsUsingBlock:^id(LocalPhoto *photo) {
        NSProgress *progress = [progressEnumerator nextObject];
        
        return [[[factory uploadFile:photo.imageURL metadata:[photo.metadata heritageDictionaryRepresentation] path:@"api/images/"]
                  then:^id _Nullable(NSDictionary * _Nonnull dictionary) {
                      progress.completedUnitCount = progress.totalUnitCount;
                      return [UploadedPhoto uploadedPhotoFrom:dictionary localPhoto:photo];
                  }] catch:^(NSError * _Nonnull error) {
                      NSLog(@"%@", error);
                  }];
    }]];
    
    Promise *resourcesPromise = [loadAll then:^id _Nullable(NSArray <UploadedPhoto *> * _Nonnull object) {
        NSArray <NSDictionary *> *resources = [object arrayByTransformingObjectsUsingBlock:^id(UploadedPhoto * image) {
            return [image dictionaryRepresentation];
        }];
        
        return [factory postRequest:[reportUpload dictionaryRepresentationWithResources:resources] path:@"api/reports/"];
    }];
    
    return [resourcesPromise then:^id _Nullable(NSDictionary * _Nonnull object) {
        return [[Promise alloc] initWithWork:^(void (^ _Nonnull fulfill)(id <ReportProtocol> _Nonnull), void (^ _Nonnull reject)(NSError * _Nonnull)) {
            
            HerBridgeReport *report = [[HerBridgeReport alloc] initWithDictionary:object];
            
            fulfill(report);
        }];
    }];
}

@end
