//
//  LTracker.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "LTracker.h"

@implementation LTracker


- (id) init {
    
    self = [super init];
    
    [[SubscriptionManager instance] addObserver:self];
    
    [GATracking instance].delegate = self;
    
    _subscriptionStatus = @"unbekannt";
    
    return self;
}


+ (instancetype) instance {
    
    static LTracker* __instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __instance = [LTracker new];
    });
    
    return __instance;
}



#pragma mark - Tracker

- (void) setTracker:(id<GAITracker>)tracker {
    
    [[GATracking instance] setTracker:tracker];
}



#pragma mark - Content Path

- (void) setContentPath:(NSString*) path {
    
    [[GATracking instance] setValue:path forCustomDimensionWithIndex:ContentPath];
}



//#pragma mark - Subscription
//
//- (void) setSubscriptionActive:(BOOL) active {
//    
//    [[GATracking instance] scheduleNewSession];
//    
//    [[GATracking instance] setValue:@(active) forCustomDimensionWithIndex:SubscriptionActive];
//}



#pragma mark - SubscriptionManagerObserver

- (void) subscriptionManagerDidUpdateSubscriptionStatusValidating:(BOOL)validating {
    
    if (!validating) {
        
        BOOL active = [SubscriptionManager instance].hasActiveSubscription;

        _subscriptionStatus = active ? @"aktives Abo" : @"kein Abo";
    }
}



#pragma mark - GATrackingDelegate

- (id) GATrackingValueForGlobalCustomTrackingDimension2 {
    
    return _subscriptionStatus;
}



@end
