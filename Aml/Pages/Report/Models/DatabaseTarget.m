//
//  DatabaseTarget.m
//  Amal
//
//  Created by Soroush Khanlou on 8/16/20.
//  Copyright © 2020 Global Heritage Fund. All rights reserved.
//

#import "DatabaseTarget.h"

NSString *DatabaseTargetMakeString(DatabaseTarget target) {
    switch (target) {
        case DatabaseTargetAmal:
            return @"amal";
        case DatabaseTargetEAMENA:
            return @"eamena";
        case DatabaseTargetLebanon:
            return @"lebanon";
    }
}

DatabaseTarget DatabaseTargetFromString(NSString *string) {
    if ([string isEqualToString:@"amal"]) {
        return DatabaseTargetAmal;
    }
    if ([string isEqualToString:@"eamena"]) {
        return DatabaseTargetEAMENA;
    }
    if ([string isEqualToString:@"lebanon"]) {
        return DatabaseTargetLebanon;
    }
    return DatabaseTargetAmal;
}
