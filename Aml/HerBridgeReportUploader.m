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
    
    id <PhotoProtocol> photo = reportUpload.photos.firstObject;
    
    [[[photo loadFullSizeImage] then:^id _Nullable(UIImage * _Nonnull image) {
        return [self.session POSTImageTo:[NSURL URLWithString:@"http://herbridge.legiongis.com/api/image/"] image:image metadata:[photo.metadata heritageDictionaryRepresentation]];
    }] then:^id _Nullable(id  _Nonnull object) {
        NSLog(@"%@", object);
        return nil;
    }];
    
    
//    [[self.session POSTJSONTaskWith:[NSURL URLWithString:@"http://herbridge.legiongis.com/api/report/"] JSONBody:[reportUpload.draft heritageDictionaryRepresentation]] then:^id _Nullable(id  _Nonnull object) {
//        NSLog(@"%@", object);
//        return nil;
//    }];
    
}

@end
