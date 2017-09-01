//
//  ExerciseTextField.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
//#import "ExerciseControl.h"
#import "ExerciseTypes.h"


//@"textColor" : self.textFieldTextColor,
//@"textColorSelected" : self.textFieldTextColor,
//@"borderColor" : self.textFieldBorderColor,
//@"borderColorSelected" : self.textFieldBorderColorSelected


extern NSString* const kExerciseTextFieldStateNew;
extern NSString* const kExerciseTextFieldStateActive;
extern NSString* const kExerciseTextFieldStateFinished;
extern NSString* const kExerciseTextFieldStateCorrect;
extern NSString* const kExerciseTextFieldStateWrong;

extern NSString* const kExerciseTextFieldBorderColor;
extern NSString* const kExerciseTextFieldBackgroundColor;
extern NSString* const kExerciseTextFieldTextColor;




typedef NS_ENUM(NSInteger, ExerciseTextFieldSolutionState) {
    
    Unchecked,
    Correct,
    Wrong
};





@interface ExerciseTextField : UITextField  {
    
    UIScrollView* _scrollView;
    
    UIColor* _currentBorderColor;
    UIColor* _currentBackgroundColor;
}


@property (nonatomic, copy) NSArray* solutionStrings;

@property (nonatomic, copy) NSDictionary* stateVisualDictionary;

@property (nonatomic, strong) UIInputViewController* inputViewController;

@property (nonatomic, assign) ExerciseInputType inputType;

@property (nonatomic, assign) UIView* scrollContainerView;

@property (nonatomic, assign) UIEdgeInsets insets;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) BOOL disableStandard;

@property (nonatomic, readonly) BOOL active;

@property (nonatomic, readonly) ExerciseTextFieldSolutionState solutionState;


//- (void) scrollToVisible;


- (void) setActive:(BOOL) active;

- (BOOL) check;

@end
