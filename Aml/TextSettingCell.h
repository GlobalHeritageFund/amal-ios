//
//  TextSettingCell.h
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "GenericSettingsCell.h"

@interface TextSettingCell : GenericSettingsCell<UITextFieldDelegate>

@property (weak) IBOutlet UITextField *textField;

@end
