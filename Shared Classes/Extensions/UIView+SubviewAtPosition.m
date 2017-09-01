//
//  UIView+SubviewAtPosition.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 28.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "UIView+SubviewAtPosition.h"

@implementation UIView (SubviewAtPosition)


- (NSArray*) subviewsAtPosition:(CGPoint) position {
    
    NSMutableArray* subviewsAtPosition = [NSMutableArray array];
    
    for (UIView* subview in self.subviews) {
        
        if ([self _subview:subview isAtPosition:position]) {
            
            [subviewsAtPosition addObject:subview];
        }
    }
    
    return subviewsAtPosition;
}


- (BOOL) _subview:(UIView*) subview isAtPosition:(CGPoint) position {
    
    return CGRectContainsPoint(subview.frame, position);
}


- (NSArray*) subviewsIntersectingRect:(CGRect) rect {
    
    NSMutableArray* subviewsIntersecting = [NSMutableArray array];
    
    for (UIView* subview in self.subviews) {
        
        if ([self _subview:subview isIntersectingRect:rect]) {
            
//            NSLog(@"intersect: %@, %@", NSStringFromCGRect(rect), subview);
            
            [subviewsIntersecting addObject:subview];
        }
    }
    
    return subviewsIntersecting;
}


- (BOOL) _subview:(UIView*) subview isIntersectingRect:(CGRect) rect {
    
    return CGRectIntersectsRect(subview.frame, rect);
}

            
@end
