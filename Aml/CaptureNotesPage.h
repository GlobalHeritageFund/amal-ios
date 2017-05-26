//
//  CaptureNotesPage.h
//  Aml
//
//  Created by Dustin Dettmer on 2/21/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericSettingsCell.h"
#import "LocalPhoto.h"

@interface CaptureNotesPage : UITableViewController<GenericSettingsCellDelegate>

@property (strong) LocalPhoto *localPhoto;

@end
