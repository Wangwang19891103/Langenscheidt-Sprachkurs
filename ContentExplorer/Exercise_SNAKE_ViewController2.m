//
//  Exercise_SNAKE_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "Exercise_SNAKE_ViewController2.h"
#import "ContentDataManager.h"


@implementation Exercise_SNAKE_ViewController2

@synthesize textView;
@synthesize topTextView;
@synthesize snakeView;


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
    
    if (self.exercise.lines.count > 1) {
        
        [self setErrorWithDescription:@"More than one line in exercise."];
        return;
    }
    
    ExerciseLine* exerciseLine = [[ContentDataManager instance] exerciseLinesForExercise:self.exercise][0];
    self.textView.text = self.exercise.instruction;
    self.topTextView.text = self.exercise.topText;
    self.snakeView.string = exerciseLine.field1;
    
    [self.snakeView createView];
}


@end
