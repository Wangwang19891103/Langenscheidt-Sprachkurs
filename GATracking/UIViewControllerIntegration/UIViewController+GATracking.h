//
//  UIViewController+GATracking.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "GATracking.h"


@interface UIViewController (GATracking)

@property (nonatomic, copy) NSString* trackingScreenName;

@property (nonatomic, copy) NSNumber* trackScreenViews;

@property (nonatomic, strong) id customTrackingDimension1;

@end
