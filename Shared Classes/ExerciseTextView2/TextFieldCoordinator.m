//
//  TextfieldCoordinator.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 27.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "TextFieldCoordinator.h"
#import "CGExtensions.h"


#define DEFAULT_SCROLLTOVISIBLE_MARGINS       UIEdgeInsetsMake(10,10,10,10)



@implementation TextFieldCoordinator


- (id) init {
    
    self = [super init];
    
    _textFields = [NSMutableArray array];
    [[KeyboardEventManager instance] addObserver:self];
    _scrollToVisibleMargins = DEFAULT_SCROLLTOVISIBLE_MARGINS;
    
    return self;
}




#pragma mark - Open First TextField

- (void) openFirstTextField {
    
    if (_textFields.count > 0) {
        
        [self _becomeResponderForTextfieldWithIndex:0];
    }
}


#pragma mark - Add Textfields

- (void) addTextField:(ExerciseTextField *)textField {
    
    [_textFields addObject:textField];
    
    textField.delegate = self;
}


- (void) addTextFields:(NSArray *)textFields {
    
    for (ExerciseTextField* textField in textFields) {
        
        [self addTextField:textField];
    }
}



#pragma mark - Setting Textfields Active

- (void) _setTextfieldActiveWithIndex:(NSInteger) index {
    
    _currentActiveTextfieldIndex = index;
    
    ExerciseTextField* textfield = _textFields[index];
    
    [textfield setActive:YES];
}


- (void) _setAllTextFieldsInactiveExceptTextFieldWithIndex:(NSInteger) index {
    
    ExerciseTextField* skippedTextfield = _textFields[index];
    
    for (ExerciseTextField* textfield in _textFields) {

        if (textfield != skippedTextfield) {
        
            [textfield setActive:NO];
        }
    }
}


- (void) setFirstTextfieldActive {
    
    if (_textFields.count != 0) {
        
        [self _setTextfieldActiveWithIndex:0];
        
        [self _setAllTextFieldsInactiveExceptTextFieldWithIndex:0];
    }
}


- (void) setLastTextfieldInactive {
    
    ExerciseTextField* lastTextField = [_textFields lastObject];
    
    if (lastTextField) {
        
        [lastTextField setActive:NO];
    }
}


- (void) _setCurrentTextFieldInactive {
    
    ExerciseTextField* textField = _textFields[_currentActiveTextfieldIndex];
    
    [textField setActive:NO];
}




#pragma mark - Skipping to textfields

- (void) _skipToTextfieldWithIndex:(NSInteger) index {
    
    [self _setTextfieldActiveWithIndex:index];
    
    [self _becomeResponderForTextfieldWithIndex:index];
    
    [self _setAllTextFieldsInactiveExceptTextFieldWithIndex:index];
}


- (void) _skipToNextTextfield {
    
    if ([self _hasNextTextField]) {
        
        NSInteger nextIndex = _currentActiveTextfieldIndex + 1;
        
        [self _skipToTextfieldWithIndex:nextIndex];
    }
}


- (BOOL) _hasNextTextField {
    
    return _textFields.count > _currentActiveTextfieldIndex + 1;
}




#pragma mark - FirstResponder


- (void) _becomeResponderForTextfieldWithIndex:(NSInteger) index {
    
    ExerciseTextField* textField = _textFields[index];
    
    BOOL shouldOpenKeyboard = [self _shouldOpenKeyboard];
    
    if (shouldOpenKeyboard) {
    
        [textField becomeFirstResponder];
    }
}


- (void) _resignFirstResponderOnCurrentTextField {
    
    ExerciseTextField* textField = _textFields[_currentActiveTextfieldIndex];
    
    [textField resignFirstResponder];
}


- (BOOL) _shouldOpenKeyboard {
    
    BOOL shouldOpenKeyboard = YES;
    
    if ([self.delegate respondsToSelector:@selector(textFieldCoordinatorShouldOpenKeyboard:)]) {
        
        shouldOpenKeyboard = [self.delegate textFieldCoordinatorShouldOpenKeyboard:self];
    }
    
    return shouldOpenKeyboard;
}





#pragma mark - Scroll To Visible

- (void) _scheduleScrollToVisible {
    
    if (_scrollView) {
    
        _needsScrollToVisible = YES;

        if ([self _readyToScrollToVisible]) {
            
            [self _performScrollToVisible];
        }
    }
}


- (BOOL) _readyToScrollToVisible {
    
    return (_needsScrollToVisible && _textFieldToScrollToVisible != nil && _keyboardFrameForScrollingKnown);
}


- (void) _performScrollToVisible {

    NSLog(@"perform scroll to visible");
    
    // coordinates in window space
    
    CGRect scrollViewFrameInWindow = [_scrollView.superview convertRect:_scrollView.frame toView:_scrollView.window];
    
    CGRect textFieldFrameInWindow = [_textFieldToScrollToVisible.superview convertRect:_textFieldToScrollToVisible.frame toView:_textFieldToScrollToVisible.window];
    
    CGFloat topLimit = scrollViewFrameInWindow.origin.y;
    CGFloat bottomLimit = _keyboardFrameForScrolling.origin.y;
    
    CGRect rectToVisible = CGRectOutset( _textFieldToScrollToVisible.frame, _scrollToVisibleMargins);
    CGRect rectToVisibleInWindow = [_textFieldToScrollToVisible.superview convertRect:rectToVisible toView:_textFieldToScrollToVisible.window];
    
    
    BOOL rectIsAboveTop = (rectToVisibleInWindow.origin.y < topLimit);
    BOOL rectIsBelowBottom = (rectToVisibleInWindow.origin.y + rectToVisibleInWindow.size.height > bottomLimit);
    
    
    CGFloat offsetAdjustment = 0;
    
    if (rectIsAboveTop) {
     
        NSLog(@"rect is above top");
        
        offsetAdjustment = -ABS(rectToVisibleInWindow.origin.y - topLimit);
    }
    else if (rectIsBelowBottom) {
        
        NSLog(@"rect is below bottom");
        
        offsetAdjustment = ABS(rectToVisibleInWindow.origin.y + rectToVisibleInWindow.size.height - bottomLimit);
    }
    
    
    if (offsetAdjustment != 0) {
    
        CGPoint currentOffset = _scrollView.contentOffset;
        CGPoint newOffset = CGPointMake(
                                        currentOffset.x,
                                        currentOffset.y + offsetAdjustment
                                        );
        
        
        
        [_scrollView setContentOffset:newOffset animated:YES];
    }
    
    _needsScrollToVisible = NO;
}


- (void) _resetScrollToVisible {
    
    _keyboardFrameForScrollingKnown = NO;
    _textFieldToScrollToVisible = nil;
}




#pragma mark - Handle TextField Events

- (void) _handleTextFieldReturn:(UITextField*) textField {
    
    if ([self _hasNextTextField]) {
        
        [self _skipToNextTextfield];
    }
    else {
        
        [self _resignFirstResponderOnCurrentTextField];
        
        BOOL shouldSetLastTextFieldInactive = ({
            
            BOOL setInactive = YES;
            
            if ([self.delegate respondsToSelector:@selector(textFieldCoordinatorShouldSetLastTextFieldInactive:)]) {
                
                setInactive = [self.delegate textFieldCoordinatorShouldSetLastTextFieldInactive:self];
            }
            
            setInactive;
        });
        
        if (shouldSetLastTextFieldInactive) {
         
            [self _setCurrentTextFieldInactive];
        }
        
        [self _reportLastTextFieldDidFinish];
    }
}


- (void) _handleDidBeginEditing:(UITextField*) textField {
    
    NSLog(@"did begin editing");

    _textFieldToScrollToVisible = textField;

    [self _scheduleScrollToVisible];
    
    [self _reportDidBeginEditing];
}


- (void) _handleDidEndEditing:(UITextField*) textField {
    
    NSLog(@"did end editing");
    
//    [self _scheduleScrollToVisible];
    
    [self _resetScrollToVisible];
}


- (void) _handleDidType:(UITextField*) textField {
    
    NSLog(@"did type");
    
    [self _scheduleScrollToVisible];
}





#pragma mark - Report to delegate

- (void) _reportLastTextFieldDidFinish {
    
    if ([self.delegate respondsToSelector:@selector(textFieldCoordinatorLastTextFieldDidFinish:)]) {
        
        [self.delegate textFieldCoordinatorLastTextFieldDidFinish:self];
    }
}


- (void) _reportDidBeginEditing {
    
    if ([self.delegate respondsToSelector:@selector(textFieldCoordinatorTextFieldDidBeginEditing:)]) {
        
        [self.delegate textFieldCoordinatorTextFieldDidBeginEditing:self];
    }
}




#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    [self _handleDidBeginEditing:textField];
}


- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [textField layoutIfNeeded];  // fix to jump animation
    
    [self _handleDidEndEditing:textField];
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [self _handleTextFieldReturn:textField];
    
    return NO;
}


- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [self _handleDidType:textField];
    
    return YES;
}




#pragma mark - KeyboardEventManagerObserver

- (void) keyboardEventManagerKeyboardWillShow:(KeyboardEventManager *)keyboardEventManager {
    
    _keyboardFrameForScrollingKnown = YES;
    _keyboardFrameForScrolling = keyboardEventManager.endKeyboardFrame;
    
    [self _scheduleScrollToVisible];
}


- (void) keyboardEventManagerKeyboardWillHide:(KeyboardEventManager *)keyboardEventManager {
    
}





#pragma mark - Dealloc

- (void) dealloc {
    
    [[KeyboardEventManager instance] removeObserver:self];
}




@end
