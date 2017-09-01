//
//  LTracker.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>

@import GATracking;
@import GATracking.UIViewControllerIntegration;
#import "SubscriptionManager.h"


#define LTrackerSetContentPath(path) GATrackingSetCustomDimension1(path)


typedef NS_ENUM(NSInteger, LTrackerCustomDimension) {
    
    ContentPath,
    SubscriptionActive
    
};


@interface LTracker : NSObject <SubscriptionManagerObserver, GATrackingDelegate> {
    
    NSString* _subscriptionStatus;
}


+ (instancetype) instance;

- (void) setTracker:(id<GAITracker>) tracker;




@end
