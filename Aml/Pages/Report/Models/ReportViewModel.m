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
#import "FirebaseReport.h"
#import <MapKit/MapKit.h>
#import "HerBridgeReport.h"

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
    if (self.report.photos.count == 0) {
        return @"";
    }
    return [dateIntervalFormatter stringFromDate:self.report.minDate toDate:self.report.maxDate];
}

- (NSString *)creationDateString {
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocalizedDateFormatFromTemplate:@"d MMMM y"];
    }
    NSString *key = NSLocalizedString(@"created-at", @"A description of when a report was created.");
    return [NSString localizedStringWithFormat:key, [dateFormatter stringFromDate:self.report.creationDate]];
}

- (CLLocationCoordinate2D)coordinateMidpoint {
    NSNumber *averageLatitude = [[[self.photos valueForKeyPath:@"metadata.latitude"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != 0"]] valueForKeyPath:@"@avg.self"];
    NSNumber *averageLongitude = [[[self.photos valueForKeyPath:@"metadata.longitude"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != 0"]] valueForKeyPath:@"@avg.self"];
    return CLLocationCoordinate2DMake(averageLatitude.doubleValue, averageLongitude.doubleValue);
}

- (NSString *)imageCountString {
    NSString *key = NSLocalizedString(@"label.photos.interpolation", @"A description of the number of items/photos in a report. #bc-ignore!");
    return [NSString localizedStringWithFormat:key, self.report.photoCount];
}

- (NSString *)email {
    return self.report.email;
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

- (BOOL)hasPrefilledEmail {
    return self.report.hasPrefilledEmail;
}

- (NSProgress *)progress {
    return self.report.progress;
}

- (BOOL)isEditable {
    return self.report.isEditable;
}

- (ReportDraft *)draft {
    return self.report.draft;
}

- (ReportUpload *)upload {
    return [(NSObject*)self.report asClassOrNil:[ReportUpload class]];
}

- (id<ReportProtocol>)finalized {
    return [(NSObject*)self.report asClassOrNil:[FirebaseReport class]] ?: [(NSObject*)self.report asClassOrNil:[HerBridgeReport class]];
}

- (BOOL)showProgressBars {
    return self.report.showProgressBars;
}

- (DatabaseTarget)databaseTarget {
    return self.report.databaseTarget;
}

@end
