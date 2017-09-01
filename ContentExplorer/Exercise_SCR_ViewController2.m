//
//  Exercise_SCR_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 17.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "Exercise_SCR_ViewController2.h"


@implementation Exercise_SCR_ViewController2

@synthesize textView;
@synthesize dndView;
@synthesize topTextView;


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}


- (id) init {
    
    self = [super init];
    
    [self initialize];
    
    return self;
}


- (void) initialize {
    
}


#pragma mark - View

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self createView];
}


- (void) createView {
    
    if (self.exerciseLines.count > 1) {
        
        [self setErrorWithDescription:@"More than one line in exercise."];
        return;
    }
    
    ExerciseLine* exerciseLine = self.exerciseLines[0];
    
    self.textView.text = self.exercise.instruction;
    self.topTextView.text = self.exercise.topText;
    self.dndView.string = exerciseLine.field1;
    
    [self.dndView createView];
}





@end
