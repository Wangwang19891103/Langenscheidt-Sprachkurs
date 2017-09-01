//
//  ExerciseTextField.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ExerciseTextField.h"
#import "ScrambledLettersInputViewController.h"
#import "DragAndDropInputViewController.h"
#import "UIScrollView+NoScroll.h"
#import "CustomKeyboardInputViewController.h"
#import "DragAndDropInputViewController.h"
#import "CGExtensions.h"



//INFO: height overrides insets


#define BORDER_WIDTH        2.0f

#define ALIGNMENT_RECT_INSETS       UIEdgeInsetsMake(3,0,3,0)

#define REPLACED_APOSTROPHES        @"’'´`"
#define REPLACEMENT_APOSTROPHE      @"'"





NSString* const kExerciseTextFieldStateNew = @"kExerciseTextFieldStateNew";
NSString* const kExerciseTextFieldStateActive = @"kExerciseTextFieldStateActive";
NSString* const kExerciseTextFieldStateFinished = @"kExerciseTextFieldStateFinished";
NSString* const kExerciseTextFieldStateCorrect = @"kExerciseTextFieldStateCorrect";
NSString* const kExerciseTextFieldStateWrong = @"kExerciseTextFieldStateWrong";

NSString* const kExerciseTextFieldBorderColor = @"kExerciseTextFieldBorderColor";
NSString* const kExerciseTextFieldBackgroundColor = @"kExerciseTextFieldBackgroundColor";
NSString* const kExerciseTextFieldTextColor = @"kExerciseTextFieldTextColor";





@implementation ExerciseTextField

@synthesize solutionStrings;
@synthesize stateVisualDictionary;
@synthesize inputType;
@synthesize scrollContainerView;
@synthesize insets;
@synthesize height;


#pragma mark - Init

- (id) init {
    
    self = [super init];
    
    [self sharedInit];
    
    return self;
}


- (void) sharedInit {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.textAlignment = NSTextAlignmentCenter;
    _solutionState = Unchecked;
    inputType = ExerciseInputTypeStandard;  // no setter
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.returnKeyType = UIReturnKeyDone;
    
}


#pragma mark - Setters

- (void) setInputType:(ExerciseInputType)p_inputType {
    
    inputType = p_inputType;
    
    [self _updateInputViewController];
}



- (void) willMoveToSuperview:(UIView *)newSuperview {
    
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        
        [self _updateStateVisuals];
        
        [self _updateInputViewController];
    }
}


- (void) didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    if (self.superview) {
        
        [self _updateScrollView];
    }
}




- (void) didMoveToWindow {
    
    [super didMoveToWindow];
    
    if (self.window) {
        
        [self _updateScrollView];
    }
}


- (void) updateConstraints {
    
    CGSize maxSize = CGSizeZero;
    
    for (NSString* solutionString in self.solutionStrings) {
        
        CGSize size = [solutionString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:nil ].size;

//        NSLog(@"size: %@", NSStringFromCGSize(size));
        
        maxSize = CGSizeMax(maxSize, size);
    }

    maxSize = CGSizeOutset(maxSize, self.insets);

    
    [self removeConstraints:self.constraints];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[self(width)]" options:0 metrics:@{@"width" : @(ceil(maxSize.width))} views:NSDictionaryOfVariableBindings(self)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(height)]" options:0 metrics:@{@"height" : @(self.height)} views:NSDictionaryOfVariableBindings(self)]];
    
    [super updateConstraints];
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (UIEdgeInsets) alignmentRectInsets {
    
    return ALIGNMENT_RECT_INSETS;
}



- (void) _updateScrollView {  // TEST: does this work as intended when theres no scrollview in superview hierarchy?
    
    UIView* superView = self.superview;
    
    while (superView) {
        
        if ([superView isKindOfClass:[UIScrollView class]]) {
            
            break;
        }
        
        superView = superView.superview;
    }
    
    _scrollView = (UIScrollView*)superView;
}



#pragma mark - Setters

- (void) setSolutionStrings:(NSArray *)p_solutionStrings {

    solutionStrings = p_solutionStrings;
    
    [self _updateInputViewController];  // !Optimize
}


- (void) setSelected:(BOOL)p_selected {
    
    [super setSelected:p_selected];
    
    [self _updateStateVisuals];
}



#pragma mark - Become First Responder

- (BOOL) becomeFirstResponder {

//    if (self.solutionState == ExerciseControlSolutionStateFresh) {
//        
//        self.solutionState = ExerciseControlSolutionStateTouched;
//    }
//
    [self setNeedsDisplay];
    
    return [super becomeFirstResponder];
}


- (BOOL) resignFirstResponder {
    
    [self setNeedsDisplay];
    
    return [super resignFirstResponder];
}




#pragma mark - Set Active 

- (void) setActive:(BOOL)active {
    
    _active = active;
    
    self.userInteractionEnabled = active;
    
    [self _updateStateVisuals];
    
    [self setNeedsDisplay];
}



#pragma mark - ExerciseControl Protocol

- (BOOL) check {
    
    BOOL isCorrect = NO;
    
    switch (self.inputType) {

        case ExerciseInputTypeStandard:
        case ExerciseInputTypeScrambledLetters:
            isCorrect = [self checkAnySolution];
            break;
            
        case ExerciseInputTypeDragAndDrop:
            isCorrect = [self checkFirstSolution];
            break;
            
        default:
            break;
    }
    

    _solutionState = isCorrect ? Correct : Wrong;
    
    [self _updateStateVisuals];
    
    
    return (_solutionState == Correct);
}


- (BOOL) checkAnySolution {

    BOOL isCorrect = NO;
    
    for (NSString* solutionString in solutionStrings) {
        
        if ([self _string:self.text isEqualToString:solutionString]) {
            
            isCorrect = YES;
            break;
        }
    }

    return isCorrect;
}


- (BOOL) checkFirstSolution {
    
    BOOL isCorrect = NO;
    NSString* solutionString = solutionStrings[0];

//    if ([[self.text lowercaseString] isEqualToString:[solutionString lowercaseString]]) {
    if ([self _string:self.text isEqualToString:solutionString]) {
    
        isCorrect = YES;
    }
    
    return isCorrect;
}


- (BOOL) _string:(NSString*) string1 isEqualToString:(NSString*) string2 {
    
    NSString* adjustedString1 = [string1 lowercaseString];
    adjustedString1 = [self _stringByReplacingApostrophes:adjustedString1];
    NSString* adjustedString2 = [string2 lowercaseString];
    adjustedString2 = [self _stringByReplacingApostrophes:adjustedString2];
    
    return [adjustedString1 isEqualToString:adjustedString2];
}


- (NSString*) _stringByReplacingApostrophes:(NSString*) string {
    
    NSMutableString* newString = [NSMutableString string];
    NSScanner* scanner = [[NSScanner alloc] initWithString:string];
    NSCharacterSet* apostropheSet = [NSCharacterSet characterSetWithCharactersInString:REPLACED_APOSTROPHES];
    
    while (![scanner isAtEnd]) {
        
        NSString* aaa;
        [scanner scanUpToCharactersFromSet:apostropheSet intoString:&aaa];
        
        if (aaa) {
        
            [newString appendString:aaa];
        }
        
        aaa = nil;
        [scanner scanCharactersFromSet:apostropheSet intoString:&aaa];
        
        for (int i = 0; i < aaa.length; ++i) {
            
            [newString appendString:REPLACEMENT_APOSTROPHE];
        }
    }

//    NSLog(@"stringByReplacingApostrophes: Before: %@ - After: %@", string, newString);

    return newString;
}



#pragma mark - View, Drawing

- (void) drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    
    NSLog(@"rect: %@", NSStringFromCGRect(rect));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);

    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);

    
    // background color
    
    if ([self isFirstResponder]) {

        CGContextSetFillColorWithColor(context, _currentBackgroundColor.CGColor);
        CGContextFillRect(context, rect);
    }

    // border
    
    CGFloat borderWidth = BORDER_WIDTH;
    CGFloat halfWidth = borderWidth * 0.5;

    CGContextSetStrokeColorWithColor(context, _currentBorderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetLineCap(context, kCGLineCapSquare);
    
    
    // points
    
//    UIEdgeInsets insets2 = (!_active) ? ALIGNMENT_RECT_INSETS : UIEdgeInsetsZero;  // insets for substraction
    UIEdgeInsets insets2 = UIEdgeInsetsZero;
    
    CGPoint topLeft = CGPointMake(0 + halfWidth + insets2.left, 0 + halfWidth + insets2.top);
    CGPoint topRight = CGPointMake(rect.size.width - halfWidth - insets2.right, 0 + halfWidth + insets2.top);
    CGPoint bottomLeft = CGPointMake(0 + halfWidth + insets2.left, rect.size.height - halfWidth - insets2.bottom);
    CGPoint bottomRight = CGPointMake(rect.size.width - halfWidth - insets2.right, rect.size.height - halfWidth - insets2.bottom);
    
    
    
    
    // bottom border
    
    CGContextMoveToPoint(context, bottomRight.x, bottomRight.y);
    CGContextAddLineToPoint(context, bottomLeft.x, bottomLeft.y);
    
    
    if (_active) {
        
        // whole border
        
        CGContextAddLineToPoint(context, topLeft.x, topLeft.y);
        CGContextAddLineToPoint(context, topRight.x, topRight.y);
        CGContextAddLineToPoint(context, bottomRight.x, bottomRight.y);
    }
    
    CGContextStrokePath(context);
    
    
    CGContextRestoreGState(context);
}



#pragma mark - Private

- (void) _updateStateVisuals {
    
    assert(self.stateVisualDictionary);
    
    NSDictionary* visualDict = nil;
    
    switch (_solutionState) {

        case Unchecked: {
            
            visualDict = _active ? self.stateVisualDictionary[kExerciseTextFieldStateActive] : self.stateVisualDictionary[kExerciseTextFieldStateFinished]; // this is not using the difference between new and finished
        }
            break;
            
        case Correct: {
            
            visualDict = self.stateVisualDictionary[kExerciseTextFieldStateCorrect];
        }
            break;
            
        case Wrong: {

            visualDict = self.stateVisualDictionary[kExerciseTextFieldStateWrong];
        }
            break;
            
        default:
            break;
    }
    
    assert(visualDict);
    

    self.textColor = visualDict[kExerciseTextFieldTextColor];
    
    _currentBackgroundColor = visualDict[kExerciseTextFieldBackgroundColor];
    
    _currentBorderColor = visualDict[kExerciseTextFieldBorderColor];
    
    [self setNeedsDisplay];
}


- (void) _updateInputViewController {

    switch (self.inputType) {
            
        case ExerciseInputTypeScrambledLetters:
        {
            CustomKeyboardInputViewController* controller = [[CustomKeyboardInputViewController alloc] init];
            controller.string = solutionStrings[0];
            controller.responder = self;
            self.inputViewController = controller;
            break;
        }
            
        case ExerciseInputTypeDragAndDrop:
        {
            DragAndDropInputViewController* controller = [[DragAndDropInputViewController alloc] init];
            controller.strings = self.solutionStrings;
            controller.responder = self;
            self.inputViewController = controller;
            break;
        }
            
        default:
            break;
    }
}


- (NSString*) description {
    
    return [NSString stringWithFormat:@"ExerciseTextField (frame = %@, solutions = %@)", NSStringFromCGRect(self.frame), self.solutionStrings];
}




- (CGRect) caretRectForPosition:(UITextPosition *)position {
    
    if (self.inputType == ExerciseInputTypeDragAndDrop) {
        
        return CGRectZero;
    }
    else {
        
        return [super caretRectForPosition:position];
    }
}


- (CGRect) textRectForBounds:(CGRect)bounds {
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, BORDER_WIDTH + 1, 0, BORDER_WIDTH + 1);
    
    CGRect insetRect = CGRectInset2(bounds, insets);
    
    return insetRect;
}


- (CGRect) editingRectForBounds:(CGRect)bounds {
    
    return [self textRectForBounds:bounds];
}


@end
