//
//  GeneralSettingsCell.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "GeneralSettingsCell.h"
#import "UserSettingsManager.h"
#import "UserProgressManager.h"


@implementation GeneralSettingsCell

- (void) didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    if (self.superview) {
    
        if (self.switchSendData) {
        
            self.switchSendData.on = [[UserSettingsManager instance][kUserSettingsSendStatisticsData] boolValue];
        }
    }
}


#pragma mark - IBAction

- (void) actionSendData {

    NSLog(@"action send data");
    
    BOOL sendData = self.switchSendData.on;
    
    [UserSettingsManager instance][kUserSettingsSendStatisticsData] = @(sendData);
}


- (void) actionReset {
    
    NSLog(@"action reset");
    
    _resetDataBlock();
}


@end
