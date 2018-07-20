//
//  Integrations.h
//  Amal
//
//  Created by Soroush Khanlou on 7/20/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Integration

- (void)setUp;

@end


@interface CrashlyticsIntegration : NSObject<Integration>

@end


@interface FirebaseIntegration : NSObject<Integration>

@end
