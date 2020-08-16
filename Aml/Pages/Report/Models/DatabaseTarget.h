//
//  DatabaseTarget.h
//  Amal
//
//  Created by Soroush Khanlou on 8/16/20.
//  Copyright © 2020 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DatabaseTarget) {
    DatabaseTargetAmal = 0,
    DatabaseTargetEAMENA,
    DatabaseTargetLebanon,
};

NSString * _Nonnull DatabaseTargetMakeString(DatabaseTarget target);

DatabaseTarget DatabaseTargetFromString(NSString * _Nonnull string);
