//
//  Report.h
//  Amal
//
//  Created by Soroush Khanlou on 7/6/17.
//  Copyright © 2017 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LocalPhoto;

@interface Report : NSObject

@property (nonatomic) NSString *title;

@property (nonatomic) NSArray<LocalPhoto *> *photos;

@end
