//
//  UIView+LayoutDebug.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "UIView+LayoutDebug.h"
#import <objc/runtime.h>


@implementation UIView (LayoutDebug)

@dynamic highlight;

NSString const *highlightKey = @"UIView.LayoutDebug.highlight";


+ (void)load {
    
    Class c = (id)self;
    
    Method m1 = class_getInstanceMethod(c, @selector(layoutSubviews));
    Method m2 = class_getInstanceMethod(c, @selector(layoutSubviews_LayoutDebugSwizzled));
    method_exchangeImplementations(m1, m2);
    
    m1 = class_getInstanceMethod(c, @selector(updateConstraints));
    m2 = class_getInstanceMethod(c, @selector(updateConstraints_LayoutDebugSwizzled));
    method_exchangeImplementations(m1, m2);

}


- (void) layoutSubviews_LayoutDebugSwizzled {
    
    NSLog(@"(LayoutDebug) %@%d : %@%@ - layoutSubviews (frame: %@)", (self.highlight ? @"❎" : @""), [self _viewDepth], [self class], (self.accessibilityLabel ? [NSString stringWithFormat:@" (%@)", self.accessibilityLabel] : @"") , NSStringFromCGRect(self.frame));
    
    [self layoutSubviews_LayoutDebugSwizzled];
}


- (void) updateConstraints_LayoutDebugSwizzled {
    
    NSLog(@"(LayoutDebug) %@%d : %@%@ - updateConstraints", (self.highlight ? @"❎" : @""), [self _viewDepth], [self class], (self.accessibilityLabel ? [NSString stringWithFormat:@" (%@)", self.accessibilityLabel] : @""));
    
    [self updateConstraints_LayoutDebugSwizzled];
}


- (uint) _viewDepth {
    
    UIView* superView = self.superview;
    uint depth = 0;
    
    while (superView) {
        
        superView = superView.superview;
        ++depth;
    }
    
    return depth;
}


- (void) setHighlight:(BOOL)p_highlight {
    
    objc_setAssociatedObject(self, &highlightKey, @(p_highlight), OBJC_ASSOCIATION_ASSIGN);
}


- (BOOL) highlight {
    
    return [objc_getAssociatedObject(self, &highlightKey) boolValue];
}

@end
