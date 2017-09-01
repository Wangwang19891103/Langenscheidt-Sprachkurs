//
//  ExerciseViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ExerciseDataViewController.h"
#import "ExerciseTypes.h"
#import "ContentDataManager.h"
#import "ExerciseCluster.h"


@implementation ExerciseDataViewController
@synthesize idLabel;
@synthesize typeLabel;
@synthesize instructionView;
@synthesize topTextView;
@synthesize field1View;
@synthesize field2View;
@synthesize field3View;
@synthesize field4View;
@synthesize field5View;
@synthesize popupFileView;
@synthesize index;
@synthesize exercise;

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    ExerciseLine* exerciseLine = [[ContentDataManager instance] exerciseLinesForExercise:self.exercise][0];
    
    self.idLabel.text = [NSString stringWithFormat:@"ID: %d", self.exercise.cluster.id];
    self.typeLabel.text = [ExerciseTypes stringForExerciseType:self.exercise.type];
    self.instructionView.text = self.exercise.instruction;
    self.topTextView.text = self.exercise.topText;
    self.field1View.text = exerciseLine.field1;
    self.field2View.text = exerciseLine.field2;
    self.field3View.text = exerciseLine.field3;
    self.field4View.text = exerciseLine.field4;
    self.field5View.text = exerciseLine.field5;
    self.popupFileView.text = self.exercise.popupFile;
}

@end
