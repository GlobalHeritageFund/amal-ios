//
//  DatabasePickerViewController.h
//  Amal
//
//  Created by Soroush Khanlou on 8/16/20.
//  Copyright © 2020 Global Heritage Fund. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatabaseTarget.h"

@class DatabasePickerViewController;

@protocol DatabasePickerViewControllerDelegate <NSObject>

- (void)databasePicker:(DatabasePickerViewController *_Nonnull)picker didPickNewDatabase:(DatabaseTarget)target;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DatabasePickerViewController : UITableViewController

@property (nonatomic) DatabaseTarget selectedDatabase;

@property id<DatabasePickerViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
