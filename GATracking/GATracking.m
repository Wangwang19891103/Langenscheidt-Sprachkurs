//
//  GATracking.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "GATracking.h"

@implementation GATracking


- (id) init {
    
    self = [super init];
    
    return self;
}


+ (instancetype) instance {
    
    static GATracking* __instance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __instance = [GATracking new];
    });
    
    return __instance;
}



#pragma mark - GAITracker

- (void) setTracker:(id<GAITracker>)tracker {
    
    _tracker = tracker;
}



#pragma mark - Screen Name

- (void) setScreenName:(NSString *)screenName {
    
    [_tracker set:kGAIScreenName value:screenName];
}



#pragma mark - Screen View

- (void) sendScreenView {
    
    // start new session if scheduled
    
    GAIDictionaryBuilder* builder = [GAIDictionaryBuilder createScreenView];
    
    if (_newSessionScheduled) {
        
        NSLog(@"GATracking: Starting new session with screen view");
        
        [builder set:@"start" forKey:kGAISessionControl];
    }
    
    [_tracker send:[builder build]];
}



#pragma mark - Sessions

- (void) scheduleNewSession {
    
    _newSessionScheduled = YES;
}



#pragma mark - Custom Dimensions

- (void) setValue:(id) value forCustomDimensionWithIndex:(NSInteger) index {
    
    [_tracker set:[GAIFields customDimensionForIndex:index]
           value:value];
}


- (id) valueForGlobalCustomTrackingDimension2 {
    
    id value = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(GATrackingValueForGlobalCustomTrackingDimension2)]) {
    
        value = [self.delegate GATrackingValueForGlobalCustomTrackingDimension2];
    }
        
    return value;
}




@end
