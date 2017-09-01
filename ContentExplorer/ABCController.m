//
//  ABCController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ABCController.h"
#import "ExerciseViewController.h"
#import "ExerciseDictionary.h"
#import "UILabel+HTML.h"


#define BOTTOM_BUTTON_TITLE_CHECK           @"Prüfen"
#define BOTTOM_BUTTON_TITLE_NEXT            @"Weiter"

#define BOTTOM_BUTTON_AREA_HEIGHT           80.0f



@implementation ABCController

@synthesize exercise;
@synthesize index;

@synthesize navigationBar;
@synthesize navigationBarContainer;
@synthesize titleLabel;
@synthesize bottomButton;
@synthesize bottomButtonAreaHeightConstraint;
@synthesize exerciseContainerView;
@synthesize scrollview;



#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}


- (void) initialize {
    
    _exerciseViewControllers = [NSMutableArray array];
}



#pragma mark - View

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    // navigation bar
    
    [self.navigationBar createView];
    
    self.navigationBar.delegate = self;
    
    [self.navigationBarContainer addSubview: self.navigationBar];
    
    [self.navigationBarContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[navigationBar]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(navigationBar)]];
    [self.navigationBarContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[navigationBar]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(navigationBar)]];
    
    
    
    // bottom button
    
    //    [self _setBottomButtonHidden:YES animated:NO];
    
    
    // exercises
    
    [self _createExerciseViewController];
    [self _showExerciseWithIndex:0 animated:NO];
    
}


//- (void) updateViewConstraints {
//
//    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.exerciseContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
//
//    [self.view addConstraint:self.widthConstraint];
//
//    [super updateViewConstraints];
//}




#pragma mark - Creating Exercise View Controllers

- (void) _createExerciseViewController {
    
    NSDictionary* exerciseDict = [ExerciseDictionary dictionaryForExercise:exercise];
    
    ExerciseViewController* controller = [ExerciseViewController viewControllerForExerciseDictionary:exerciseDict];
    
    [_exerciseViewControllers addObject:controller];
}




#pragma mark - Managing Exercise View Controllers

- (void) _showExerciseWithIndex:(NSInteger) index animated:(BOOL) animated {
    
    ExerciseViewController* controller = _exerciseViewControllers[index];
    
    [self _showExerciseViewController:controller animated:animated];
    
    self.titleLabel.text = controller.exerciseDict[@"instruction"];
    [self.titleLabel parseHTML];
}


- (void) _showExerciseViewController:(ExerciseViewController*) controller animated:(BOOL) animated {
    
    [self.exerciseContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.exerciseContainerView addSubview:controller.view];
    
    
    UIView* controllerView = controller.view;
    
    controllerView.translatesAutoresizingMaskIntoConstraints = NO;  // this is apparently necessary...
    
    [self.exerciseContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[controllerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(controllerView)]];
    [self.exerciseContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[controllerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(controllerView)]];
}



#pragma mark - Bottom Button

- (void) _setBottomButtonHidden:(BOOL) hidden animated:(BOOL) animated {
    
    self.bottomButtonAreaHeightConstraint.constant = (hidden) ? 0 : BOTTOM_BUTTON_AREA_HEIGHT;
    [self.view setNeedsUpdateConstraints];
    
    if (animated) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self.view layoutIfNeeded];
        [UIView commitAnimations];
    }
    else {
        
        [self.view layoutIfNeeded];
    }
}


- (void) _showBottomButtonCheck {
    
    [self.bottomButton setTitle:BOTTOM_BUTTON_TITLE_CHECK forState:UIControlStateNormal];
    
    [self _setBottomButtonHidden:NO animated:YES];
}


- (void) _showBottomButtonNext {
    
    [self.bottomButton setTitle:BOTTOM_BUTTON_TITLE_NEXT forState:UIControlStateNormal];
    
    [self _setBottomButtonHidden:NO animated:YES];
}


- (IBAction) handleBottomButtonTapped {
    
}



#pragma mark - Delegates

- (void) exerciseNavigationBarDidReceiveCloseCommand:(ExerciseNavigationBar *)navigationBar {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
