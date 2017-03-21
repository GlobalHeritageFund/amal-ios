//
//  SliderSettingCell.h
//  Amal
//
//  Created by Dustin Dettmer on 3/20/17.
//  Copyright © 2017 Dustin. All rights reserved.
//

#import "GenericSettingsCell.h"

@interface SliderSettingCell : GenericSettingsCell

@property (weak) IBOutlet UISlider *slider;

@property (assign) BOOL roundValueChanges;

@end
