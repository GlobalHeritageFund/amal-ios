//
//  ReportViewModel.m
//  Amal
//
//  Created by Soroush Khanlou on 8/25/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import "ReportViewModel.h"

@implementation ReportViewModel

- (instancetype)initWithReport:(id<ReportProtocol>)report {
    self = [super init];
    if (!self) return nil;

    _report = report;

    return self;
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

- (NSString *)photoCountString {
    if (self.report.photoCount == 0) {
        return @"No photos";
    } else if (self.report.photoCount == 1) {
        return @"1 photo";
    } else {
        return [NSString stringWithFormat:@"%zd photos", self.report.photoCount];
    }
}

- (NSString *)uploadState {
    return self.report.uploadState;
}

- (NSString *)reportState {
    return self.report.reportState;
}

- (NSProgress *)progress {
    return self.report.progress;
}

@end
