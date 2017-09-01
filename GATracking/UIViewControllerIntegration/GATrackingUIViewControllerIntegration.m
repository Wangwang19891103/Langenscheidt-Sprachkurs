//
//  GATrackingMacros.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "GATrackingUIViewControllerIntegration.h"
#import <objc/runtime.h>
#import "GATracking.h"


NSString* const kGATrackingScreenNameKey = @"trackingScreenName";
NSString* const kGATrackScreenViewsKey = @"trackScreenViews";
NSString* const kGACustomTrackingDimension1Key = @"customTrackingDimension1";


void setScreenNameForViewController(id controller, NSString* firstArg, ...) {
    
    if ([controller isKindOfClass:[UIViewController class]]) {
        
        Class class = [controller class];
        const char* propertyChars = [kGATrackingScreenNameKey cStringUsingEncoding:NSUTF8StringEncoding];
        BOOL hasProperty = class_getProperty(class, (const char*)propertyChars);
        
        if (hasProperty) {
            
            NSLog(@"GATracking: UIViewController class has property");
            
            va_list args;
            va_start(args, firstArg);
            
            NSString* screenName = [[NSString alloc] initWithFormat:firstArg arguments:args];
            
            va_end(args);
            
            [controller setValue:screenName forKey:kGATrackingScreenNameKey];
        }
    }
    
}


void setTrackScreenViewsForViewController(id controller, BOOL shouldTrack) {
    
    if ([controller isKindOfClass:[UIViewController class]]) {

        [controller setValue:@(shouldTrack) forKey:kGATrackScreenViewsKey];
    }
}


void setCustomTrackingDimension1ForViewController(id controller, id value) {
    
    if ([controller isKindOfClass:[UIViewController class]]) {
        
        [controller setValue:value forKey:kGACustomTrackingDimension1Key];
    }
}

