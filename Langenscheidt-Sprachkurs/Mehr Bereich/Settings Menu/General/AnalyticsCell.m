//
//  AnalyticsCell.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "AnalyticsCell.h"

@implementation AnalyticsCell


- (IBAction) actionAnalytics {
    
    BOOL activated = _analyticsSwitch.on;
    
    _buttonBlock(activated);
}


- (void) setActivated:(BOOL)p_activated {
    
    _activated = p_activated;
    
    _analyticsSwitch.on = _activated;
}


@end
