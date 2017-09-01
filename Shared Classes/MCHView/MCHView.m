//
//  MCHView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "MCHView.h"
#import "MCHButton.h"
#import "UIView+RemoveConstraints.h"
#import "NSArray+Extensions.h"
#import "ExerciseViewController.h"
#import "Exercise_MCH_ViewController.h"





#define CORRECT_BUTTON_TAG          1000

#define SCORE_FOR_CORRECT_ANSWER        3
#define SCORE_FOR_CORRECT_ANSWER_LISTENINGCOMPREHENSION        7



@implementation MCHView

@synthesize spacing;



#pragma mark - Init

- (id) init {
    
    self = [super init];
    
    [self initialize];
    
    return self;
}


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}


- (void) initialize {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    _maxScore = SCORE_FOR_CORRECT_ANSWER;
    _maxScore_Listening = SCORE_FOR_CORRECT_ANSWER_LISTENINGCOMPREHENSION;
}



#pragma mark - View, Layout, Constraints

- (void) createView {
    
    [self _createButtons];
}


- (void) _createButtons {
    
    NSMutableArray* buttons = [NSMutableArray array];
    
    for (NSString* answer in self.answers) {
        
        MCHButton* button = [[MCHButton alloc] init];
        button.userInteractionEnabled = YES;
        [button addGestureRecognizer:[self _createTapGestureRecognizer]];
        
        if ([self _answerIsSolution:answer]) {
            
            button.string = [self _stringInGaps:answer];
            button.tag = CORRECT_BUTTON_TAG;
        }
        else {
            
            button.string = answer;
        }

        [button createView];

        [buttons addObject:button];
    }
    
    _buttons = [NSArray randomizedArrayFromArray:buttons];
    
    for (UIView* button in _buttons) {
        
        [self addSubview:button];
    }
}


- (void) layoutSubviews {
    
    [super layoutSubviews];
}


- (void) updateConstraints {
    
    // ...
    
    [self _arrangeSubviews];
    
    [self invalidateIntrinsicContentSize];
    
    [super updateConstraints];
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}



#pragma mark - View Logic

- (void) _arrangeSubviews {
    
    for (UIView* subview in self.subviews) {
        
        [self removeConstraintsAffectingSubview:subview];
    }

    
    UIView* previousView = nil;
    
    for (uint i = 0; i < self.subviews.count; ++i) {
    
        UIView* subview = self.subviews[i];

        
        // horizontal
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[subview]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview)]];

        
        // vertical
        
        if (i == 0) {
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[subview]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview)]];
        }
        else {

            assert(previousView);
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-(spacing)-[subview(previousView)]" options:0 metrics:@{@"spacing" : @(self.spacing)} views:NSDictionaryOfVariableBindings(subview, previousView)]];
        }

        if (i == self.subviews.count - 1) {
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subview]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview)]];
        }

        previousView = subview;
    }
}



#pragma mark - Button Tap

- (UITapGestureRecognizer*) _createTapGestureRecognizer {

    return [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
}


- (void) _handleTap:(UIGestureRecognizer*) recognizer {
    
    NSLog(@"Tap");
    
//    [self _performCheckWithTappedButton:recognizer.view];
    
//    [self _deselectAllButtons];
    
    MCHButton* button = (MCHButton*)recognizer.view;
    
    button.buttonState = Selected;
    
    [self.delegate MCHViewButtonTapped];

}


- (void) _deselectAllButtons {
    
    for (MCHButton* button in _buttons) {

        button.buttonState = Normal;
    }
}



#pragma mark - Check Logic

- (void) _performCheckWithTappedButton:(MCHButton*) tappedButton {
    
    for (MCHButton* button in _buttons) {
        
        if (button.tag == CORRECT_BUTTON_TAG) {
            
            button.buttonState = Correct;
        }
        else if (button == tappedButton) {
            
            if (tappedButton.tag != CORRECT_BUTTON_TAG) {
                
                tappedButton.buttonState = Wrong;
            }
        }
        else {
            
            button.buttonState = Normal;
        }
    }
    
}



#pragma mark - Utility

- (BOOL) _answerIsSolution:(NSString*) string {
    
    return (
            [[string substringToIndex:1] isEqualToString:@"["]
            &&
            [[string substringFromIndex:string.length - 1] isEqualToString:@"]"]
            );
}


- (NSString*) _stringInGaps:(NSString*) string {
    
    return [string substringWithRange:NSMakeRange(1, string.length - 2)];
}



- (BOOL) check {
    
    BOOL correct = YES;
    NSInteger score = 0;
    NSInteger score_Listening = 0;
    
    Exercise_MCH_ViewController* instance;
    
    NSString* audioFile = instance.exerciseDict[@"audioFile"];
    
    
    
    NSLog(@"audiofile is %@", audioFile);
    
    self.userInteractionEnabled = NO;
    
    
    for (MCHButton* button in _buttons) {
        


        if (button.tag == CORRECT_BUTTON_TAG) {
            
            if (button.buttonState == Selected) {
                
                button.buttonState = Correct;
                score = SCORE_FOR_CORRECT_ANSWER;
                score_Listening = SCORE_FOR_CORRECT_ANSWER_LISTENINGCOMPREHENSION;
            }
            else if (button.buttonState == Normal) {
                
                button.buttonState = Missed;
                correct = NO;
            }
            
            
        }
        
        else if (button.buttonState == Selected && button.tag != CORRECT_BUTTON_TAG) {
            
            button.buttonState = Wrong;
            correct = NO;
        }
        
    }
    
    _scoreAfterCheck = score;
    _scoreAfterCheck_Listening = score_Listening;
    
    
    return correct;
}



#pragma mark - Interface Builder

- (void) prepareForInterfaceBuilder {
    
    self.answers = @[
                        @"[in London yesterday morning, in London yesterday morning]",
                        @"morning yesterday in London",
                        @"London yesterday in morning"
                        ];
    
    [self createView];
}

@end
