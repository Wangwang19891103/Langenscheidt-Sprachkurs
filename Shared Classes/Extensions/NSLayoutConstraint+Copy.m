//
//  NSLayoutConstraint+Copy.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 13.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "NSLayoutConstraint+Copy.h"

@implementation NSLayoutConstraint (Copy)

- (id) copyWithZone:(NSZone *)zone {

    NSLayoutConstraint* copy = [NSLayoutConstraint constraintWithItem:self.firstItem attribute:self.firstAttribute relatedBy:self.relation toItem:self.secondItem attribute:self.secondAttribute multiplier:self.multiplier constant:self.constant];
    
    return copy;
}

@end
