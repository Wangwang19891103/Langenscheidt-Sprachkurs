//
//  ExerciseContentViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ExerciseContentViewController.h"
#import "ContentDataManager.h"


@implementation ExerciseContentViewController

@synthesize exercise;
@synthesize exerciseLines;
@synthesize hasError;
@synthesize errorDescription;


- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
}


- (void) setExercise:(Exercise *)p_exercise {
    
    exercise = p_exercise;
    
    self.exerciseLines = [[ContentDataManager instance] exerciseLinesForExercise:self.exercise];
}



- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];

}


- (void) setErrorWithDescription:(NSString*) description {
    
    self.hasError = YES;
    self.errorDescription = description;
}


@end
