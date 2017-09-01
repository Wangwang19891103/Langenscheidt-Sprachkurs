//
//  GATrackingMacros.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

@import UIKit;


#define GATrackingSetScreenName(firstArg, ...) setScreenNameForViewController(self, firstArg, ##__VA_ARGS__)

#define GATrackingSetTrackScreenViews(shouldTrack) setTrackScreenViewsForViewController(self, shouldTrack)

#define GATrackingSetCustomDimension1(value) setCustomTrackingDimension1ForViewController(self, value)



void setScreenNameForViewController(id controller, NSString* firstArg, ...);

void setTrackScreenViewsForViewController(id controller, BOOL shouldTrack);

void setCustomTrackingDimension1ForViewController(id controller, id value);

