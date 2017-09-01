//
//  Exercise_SNAKE_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "Exercise_MATCHER_ViewController2.h"
#import "ContentDataManager.H"

@implementation Exercise_MATCHER_ViewController2

@synthesize textView;
@synthesize topTextView;
@synthesize matcherView;


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
    
    self.textView.text = self.exercise.instruction;
    self.topTextView.text = self.exercise.topText;

    self.matcherView.pairs = [self _createPairs];
    
    [self.matcherView createView];
}


- (NSArray*) _createPairs {  //FIX
    
    NSMutableArray* pairs = [NSMutableArray array];
    
    NSArray* exerciseLines = [[ContentDataManager instance] exerciseLinesForExercise:self.exercise];
    
    for (ExerciseLine* exerciseLine in exerciseLines) {
        
        NSString* field1 = exerciseLine.field1;
        NSString* field2 = exerciseLine.field2;
        
        if (!field1 || !field2) {
            
            [self setErrorWithDescription:@"Missing field1 and/or field2 in exercise."];
            return nil;
        }
        
        [pairs addObject:@[
                           exerciseLine.field1,
                           exerciseLine.field2
                           ]];
    }
    
    return pairs;
}

@end








