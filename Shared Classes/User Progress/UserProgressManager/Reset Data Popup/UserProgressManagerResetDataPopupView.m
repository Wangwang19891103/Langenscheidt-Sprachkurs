//
//  UserProgressManagerResetDataPopupView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 24.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "UserProgressManagerResetDataPopupView.h"


#define RESET_DATA_POPUP_FILE       @"UserProgressManagerResetDataPopupView"



@implementation UserProgressManagerResetDataPopupView


- (id) init {
    
    self = [[[UINib nibWithNibName:RESET_DATA_POPUP_FILE bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] firstObject];

    return self;
}


- (IBAction) actionConfirm:(id)sender {
    
    _confirmBlock();
}


- (IBAction) actionCancel:(id)sender {
    
    _cancelBlock();
}


@end
