//
//  UIView+RemoveConstraints.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 17.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "UIView+RemoveConstraints.h"

@implementation UIView (RemoveConstraints)


- (void) removeConstraintsAffectingSubview:(UIView *)subview {
    
    for (NSLayoutConstraint* constraint in self.constraints) {
        
        if (constraint.firstItem == subview || constraint.secondItem == subview) {
            
            [self removeConstraint:constraint];
        }
    }
}


@end