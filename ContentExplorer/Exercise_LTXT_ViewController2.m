//
//  Exercise_LTXT_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "Exercise_LTXT_ViewController2.h"
#import "UIView+Extensions.h"
#import "NSLayoutConstraint+Copy.h"
#import "ExerciseTextField.h"
#import "ExerciseLine.h"
#import "ExerciseTextView2.h"

@implementation Exercise_LTXT_ViewController2

@synthesize topTextView;
//@synthesize prototypeTextView;
@synthesize contentStackView;


- (id) init {
    
    self = [super initWithNibName:@"Exercise_LTXT_ViewController" bundle:[NSBundle mainBundle]];
    
    return self;
}


- (void)viewDidLoad {

    [super viewDidLoad];
    
    
    [self.contentStackView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [self.contentStackView addSubview:self.topTextView];
    
    
    [self createViews];
    
}





- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    NSLog(@"LTXT - viewDidLayoutSubviews");
}


- (void) createViews {
    
    NSLog(@"LTXT - createViews");
    
    // Top Text
    
    if (self.exercise.topText) {
        
        self.topTextView.text = self.exercise.topText;
    }
    else {

//        [self.topTextView removeFromSuperview];
//        self.topTextView = nil;
    }
    
    // ---
    
    
    if (self.exercise.lines.count > 1) {
        
        [self setErrorWithDescription:@"More than one line in exercise."];
        return;
    }
    
    
    NSMutableArray* fieldStrings = [NSMutableArray array];
    
    ExerciseLine* exerciseLine = self.exercise.lines.anyObject ;  // only 1 line used
    
    if (exerciseLine.field1) [fieldStrings addObject:exerciseLine.field1];
    if (exerciseLine.field2) [fieldStrings addObject:exerciseLine.field2];
    if (exerciseLine.field3) [fieldStrings addObject:exerciseLine.field3];
    if (exerciseLine.field4) [fieldStrings addObject:exerciseLine.field4];
    if (exerciseLine.field5) [fieldStrings addObject:exerciseLine.field5];
    
    
//    UIView* aboveView = self.topTextView;
    
    for (NSString* fieldString in fieldStrings) {
        
        NSLog(@"%@", fieldString);
        
        ExerciseTextView* textView = [self newTextView];
        
        [self.contentStackView addSubview:textView];
        
        textView.string = fieldString;
        [textView createView];

        [textView.textFields makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
        
//        aboveView = textView;
    }
    
//    self.view.backgroundColor = [UIColor yellowColor];
    
    NSLog(@"%@", self.view.constraints);
}


- (ExerciseTextView*) newTextView {
    
//    ExerciseTextView* textView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.prototypeTextView]];

    ExerciseTextView2* textView = [[ExerciseTextView2 alloc] init];
    
    //    textView.fontName = self.prototypeTextView.fontName;
//    textView.fontSize = self.prototypeTextView.fontSize;
//    textView.fontColor = self.prototypeTextView.fontColor;
//    textView.textLayerAdjustmentY = self.prototypeTextView.textLayerAdjustmentY;
//    textView.lineSpacing = self.prototypeTextView.lineSpacing;
//    textView.textFieldHeight = self.prototypeTextView.textFieldHeight;
//    textView.textFieldAdjustmentWidth = self.prototypeTextView.textFieldAdjustmentWidth;
//    textView.textFieldBackgroundColor = self.prototypeTextView.textFieldBackgroundColor;
//    textView.textFieldBorderColor = self.prototypeTextView.textFieldBorderColor;
//    textView.textFieldBackgroundColorCorrect = self.prototypeTextView.textFieldBackgroundColorCorrect;
//    textView.textFieldBackgroundColorWrong = self.prototypeTextView.textFieldBackgroundColorWrong;
//    textView.textFieldBorderColorSelected = self.prototypeTextView.textFieldBorderColorSelected;
    textView.inputType = [ExerciseTypes inputTypeForExerciseType:self.exercise.type];
    
    if (textView.inputType == ExerciseInputTypeDragAndDrop) {
        
        textView.generateSharedSolutions = YES;
    }
    
    return textView;
}


#pragma  mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    [(ExerciseTextField*)textField setSelected:YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [(ExerciseTextField*)textField check];
    [(ExerciseTextField*)textField setSelected:NO];
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}

@end
