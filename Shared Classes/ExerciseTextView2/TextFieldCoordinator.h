//
//  TextfieldCoordinator.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseTextField.h"
#import "KeyboardEventManager.h"
@import UIKit;


@protocol TextFieldCoordinatorDelegate;



@interface TextFieldCoordinator : NSObject <UITextFieldDelegate, KeyboardEventManagerObserver> {
    
    NSInteger _currentActiveTextfieldIndex;
    
    
    // scroll to visible
    
    BOOL _needsScrollToVisible;
    BOOL _keyboardFrameForScrollingKnown;
    CGRect _keyboardFrameForScrolling;
    UITextField* _textFieldToScrollToVisible;
}

@property (nonatomic, strong) NSMutableArray* textFields;

@property (nonatomic, assign) UIScrollView* scrollView;  // set this to manage scrollToVisible

@property (nonatomic, assign) UIEdgeInsets scrollToVisibleMargins;

@property (nonatomic, assign) id<TextFieldCoordinatorDelegate> delegate;


- (void) addTextField:(ExerciseTextField*) textField;

- (void) addTextFields:(NSArray*) textFields;



- (void) setFirstTextfieldActive;

- (void) openFirstTextField;

- (void) setLastTextfieldInactive;


@end



@protocol TextFieldCoordinatorDelegate <NSObject>

- (void) textFieldCoordinatorTextFieldDidBeginEditing:(TextFieldCoordinator*) coordinator;

- (void) textFieldCoordinatorLastTextFieldDidFinish:(TextFieldCoordinator*) coordinator;

- (BOOL) textFieldCoordinatorShouldOpenKeyboard:(TextFieldCoordinator*) coordinator;

- (BOOL) textFieldCoordinatorShouldSetLastTextFieldInactive:(TextFieldCoordinator*) coordinator;

@end