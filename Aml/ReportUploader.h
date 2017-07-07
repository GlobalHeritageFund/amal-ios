//
//  ReportUploader.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Report;

@interface ReportUploader : NSObject

- (void)upload:(Report *)report completion:(void (^)())completion;

@end
