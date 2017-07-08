//
//  ReportUploader.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Promise.h"

@class Report;

@interface ReportUploader : NSObject

- (Promise<Report *> *)upload:(Report *)report;

@end
