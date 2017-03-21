//
//  GenericSettingsCell.h
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GenericSettingsCell;

@protocol GenericSettingsCellDelegate <NSObject>

- (void)reportValueChange:(id)value forCell:(GenericSettingsCell*)cell;

@end

@interface GenericSettingsCell : UITableViewCell

@property (weak) id<GenericSettingsCellDelegate> delegate;

@property (strong) NSString *settingsKey;

- (void)setValue:(id)value;

@end
