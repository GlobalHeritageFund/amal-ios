//
//  ReportViewModel.m
//  Amal
//
//  Created by Soroush Khanlou on 8/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportViewModel.h"
#import "NSObject+Helpers.h"
#import "ReportDraft.h"
#import "ReportUpload.h"
#import "Report.h"

@implementation ReportViewModel

- (instancetype)initWithReport:(id<ReportProtocol>)report {
    self = [super init];
    if (!self) return nil;

    _report = report;

    return self;
}

- (NSString *)title {
    return self.report.title;
}

- (NSArray<id<PhotoProtocol>> *)photos {
    return self.report.photos;
}

static NSDateIntervalFormatter *dateIntervalFormatter = nil;

static NSDateFormatter *dateFormatter = nil;

- (NSString *)dateInterval {
    if (dateIntervalFormatter == nil) {
        dateIntervalFormatter = [[NSDateIntervalFormatter alloc] init];
        dateIntervalFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateIntervalFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    return [dateIntervalFormatter stringFromDate:self.report.minDate toDate:self.report.maxDate];
}

- (NSString *)creationDateString {
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"d MMMM yyyy";
    }
    return [NSString stringWithFormat:@"Created %@", [dateFormatter stringFromDate:self.report.creationDate]];
}

- (NSString *)imageCountString {
    if (self.report.photoCount == 0) {
        return @"No items";
    } else if (self.report.photoCount == 1) {
        return @"1 item";
    } else {
        return [NSString stringWithFormat:@"%zd items", self.report.photoCount];
    }
}

- (NSString *)uploadState {
    return self.report.uploadState;
}

- (NSString *)reportState {
    return self.report.reportState;
}

- (UIColor *)reportStateColor {
    return self.report.reportStateColor;
}

- (NSProgress *)progress {
    return self.report.progress;
}

- (BOOL)isEditable {
    return self.report.isEditable;
}

- (ReportDraft *)draft {
    return [(NSObject*)self.report asClassOrNil:[ReportDraft class]];
}

- (ReportUpload *)upload {
    return [(NSObject*)self.report asClassOrNil:[ReportUpload class]];
}

- (Report *)finalized {
    return [(NSObject*)self.report asClassOrNil:[Report class]];
}

@end
