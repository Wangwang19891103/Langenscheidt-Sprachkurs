//
//  UIViewController+GATracking.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "UIViewController+GATracking.h"

#import <objc/runtime.h>


@implementation UIViewController (GATracking)

@dynamic trackingScreenName;
@dynamic trackScreenViews;
@dynamic customTrackingDimension1;



#pragma mark - Class

+ (void) load {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzledSelector = @selector(GATracking_viewWillAppear:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
}



#pragma mark - Tracking Screen Name

- (void) setTrackingScreenName:(NSString *)trackingScreenName {
    
    objc_setAssociatedObject(self, @selector(trackingScreenName), trackingScreenName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (NSString*) trackingScreenName {
    
    return (NSString*)objc_getAssociatedObject(self, @selector(trackingScreenName));
}



#pragma mark - Track Screen Views

- (void) setTrackScreenViews:(NSNumber*)trackScreenViews {
    
    objc_setAssociatedObject(self, @selector(trackScreenViews), trackScreenViews, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (NSNumber*) trackScreenViews {
    
    return (NSNumber*)objc_getAssociatedObject(self, @selector(trackScreenViews));
}




#pragma mark - Custom Tracking Dimension 1

- (void) setCustomTrackingDimension1:(id)customTrackingDimension1 {
    
    objc_setAssociatedObject(self, @selector(customTrackingDimension1), customTrackingDimension1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (id) customTrackingDimension1 {
    
    return objc_getAssociatedObject(self, @selector(customTrackingDimension1));
}



#pragma mark - GATracking Integration

- (void) GATracking_viewWillAppear:(BOOL) animated {
    
    [self GATracking_viewWillAppear:animated];
    
    
    // GATracking Integration code
    
    // screen name
    
    NSLog(@"GATracking: viewDidAppear (screen name: %@)", self.trackingScreenName);
    
    [[GATracking instance] setScreenName:self.trackingScreenName];

    
    
    
    // screen view if tracked
    
    if (self.trackScreenViews) {

        // custom tracking dimension 1
        
        [[GATracking instance] setValue:nil forCustomDimensionWithIndex:1];
        
        if (self.customTrackingDimension1) {
            
            NSLog(@"GATracking: setting custom dimension1 to \"%@\"", self.customTrackingDimension1);
            
            [[GATracking instance] setValue:self.customTrackingDimension1 forCustomDimensionWithIndex:1];
        }
        
        
        // custom tracking dimension 2 (global, get from delegate)
        
        id dimension2value = [[GATracking instance] valueForGlobalCustomTrackingDimension2];
        
        if (dimension2value) {
            
            NSLog(@"GATracking: setting global custom dimension2 to \"%@\"",dimension2value);
            
            [[GATracking instance] setValue:dimension2value forCustomDimensionWithIndex:2];
        }
        else {
            
            NSLog(@"GATracking: value for global custom dimension2 not found!");
        }

        
        NSLog(@"GATracking: sending screen view");
        
        [[GATracking instance] sendScreenView];
    }
}

@end
