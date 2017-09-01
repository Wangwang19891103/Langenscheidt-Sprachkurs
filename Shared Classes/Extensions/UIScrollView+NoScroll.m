//
//  UIScrollView+NoScroll.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 07.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "UIScrollView+NoScroll.h"
#import <objc/runtime.h>


@implementation UIScrollView (NoScroll)


+ (void)load {
    
    Class c = (id)self;
    
    // Use class_getInstanceMethod for "normal" methods
    Method m1 = class_getInstanceMethod(c, @selector(scrollRectToVisible:animated:));
    Method m2 = class_getInstanceMethod(c, @selector(scrollRectToVisible_hidden:animated:));
    
    // Swap the two methods.
    method_exchangeImplementations(m1, m2);
}


- (void) scrollRectToVisible2:(CGRect)rect animated:(BOOL)animated {
    
    [self scrollRectToVisible_hidden:rect animated:animated];
}


- (void) scrollRectToVisible_hidden:(CGRect)rect animated:(BOOL)animated {
    
}



@end
