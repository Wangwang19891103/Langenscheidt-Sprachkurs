//
//  GATracking.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAILogger.h"



@protocol GATrackingDelegate;




@interface GATracking : NSObject {
    
    id<GAITracker> _tracker;
    
    BOOL _newSessionScheduled;
}


@property (nonatomic, assign) id<GATrackingDelegate> delegate;


+ (instancetype) instance;

- (void) setTracker:(id<GAITracker>) tracker;

- (void) setScreenName:(NSString*) screenName;

- (void) sendScreenView;

- (void) scheduleNewSession;

- (void) setValue:(id) value forCustomDimensionWithIndex:(NSInteger) index;

- (id) valueForGlobalCustomTrackingDimension2;


@end



@protocol GATrackingDelegate <NSObject>

- (id) GATrackingValueForGlobalCustomTrackingDimension2;

@end
