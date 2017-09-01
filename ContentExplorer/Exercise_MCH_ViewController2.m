//
//  Exercise_MCH_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "Exercise_MCH_ViewController2.h"
#import "ContentDataManager.h"
#import "NSString+Clean.h"


@implementation Exercise_MCH_ViewController2

@synthesize textView;
@synthesize topTextView;
@synthesize mchView;


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
    
    self.mchView.answers = [self _createAnswers];
    
    [self.mchView createView];
}


- (NSArray*) _createAnswers {
    
    NSMutableArray* answers = [NSMutableArray array];
    
    NSArray* exerciseLines = [[ContentDataManager instance] exerciseLinesForExercise:self.exercise];

    if (exerciseLines.count > 1) {
        
        [self setErrorDescription:@"More than one line in exercise."];
    }
    
    ExerciseLine* line = exerciseLines[0];
    
    if (line.field1) [answers addObject:[line.field1 cleanString]];
    if (line.field2) [answers addObject:[line.field2 cleanString]];
    if (line.field3) [answers addObject:[line.field3 cleanString]];
    if (line.field4) [answers addObject:[line.field4 cleanString]];
    if (line.field5) [answers addObject:[line.field5 cleanString]];
    
    return answers;
}


@end
