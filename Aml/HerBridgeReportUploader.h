//
//  HerBridgeReportUploader.h
//  Amal
//
//  Created by Kenneth Parker Ackerson on 8/14/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReportUpload;
@interface HerBridgeReportUploader : NSObject

- (instancetype)initWithSession:(NSURLSession *)session progresses:(NSArray <NSProgress *> *)progresses;

- (void)uploadReport:(ReportUpload *)reportUpload;

@end
