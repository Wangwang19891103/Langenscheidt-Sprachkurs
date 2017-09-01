//
//  ExerciseReorderableView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ExerciseReorderableLabel.h"



@implementation ExerciseReorderableLabel

@synthesize normalBackgroundColor;
@synthesize ghostBackgroundColor;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}


- (instancetype) init {
    
    self = [super init];
    
    [self initialize];
    
    return self;
}


- (void) initialize {

    [self setNormalAppearance];
}


- (void) didMoveToSuperview {
    
    if (self.superview) {
        
        [self setNormalAppearance];
    }
}


- (void) setNormalAppearance {

    self.backgroundColor = self.normalBackgroundColor;
}


- (void) setGhostAppearance {
    
    self.backgroundColor = self.ghostBackgroundColor;
}

@end
