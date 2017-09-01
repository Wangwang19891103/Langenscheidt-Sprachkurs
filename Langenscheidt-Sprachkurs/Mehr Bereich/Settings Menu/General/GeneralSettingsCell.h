//
//  GeneralSettingsCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface GeneralSettingsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UISwitch* switchSendData;

@property (nonatomic, strong) void (^resetDataBlock)();

- (IBAction) actionSendData;
- (IBAction) actionReset;

@end
