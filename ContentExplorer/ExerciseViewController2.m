//
//  ExerciseViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ExerciseViewController2.h"
#import "ExerciseTypes.h"

#import "Exercise_LTXT_ViewController2.h"
#import "UIView+Extensions.h"
#import "ErrorViewController.h"
#import "ExerciseCluster.h"
#import "ExerciseViewController.h"


@implementation ExerciseViewController2

@synthesize index;
@synthesize exercise;


// remove later
@synthesize idLabel;
@synthesize typeLabel;
// ---

@synthesize exerciseContentViewController;
@synthesize exerciseContainerView;

@synthesize bottomDummyView;
@synthesize bottomDummyHeightConstraint;



//- (id) initWithExercise:(Exercise*) p_exercise {
//    
//    self = [self.storyboard instantiateViewControllerWithIdentifier:@"ExerciseBase"];
//    
//    exercise = p_exercise;
//    
//    
//    return self;
//}


- (void) keyboardWillChangeFrame:(NSNotification*) notification {
    
    NSDictionary* userInfo = notification.userInfo;
    
//    NSLog(@"%@", userInfo);
    
//    CGRect newFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    
    
    CGRect endFrame = [self.view convertRect:[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    CGFloat height = MAX(self.view.frame.size.height - endFrame.origin.y, 0);
    
//    NSLog(@"new keyboard height relative to self.view: %f", height);

    
    self.bottomDummyHeightConstraint.constant = height;
    [self.view setNeedsUpdateConstraints];

    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}


- (void)viewDidLoad {

    [super viewDidLoad];

    self.idLabel.text = [NSString stringWithFormat:@"ID: %d", self.exercise.cluster.id];
    self.typeLabel.text = [ExerciseTypes stringForExerciseType:self.exercise.type];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillHideNotification object:nil];

    [self insertExerciseContent];
}


- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    
}


- (void) insertExerciseContent {

    
    switch (exercise.type) {
            
        case LTXT_STANDARD:
        case LTXT_STANDARD_TABULAR:
        case LTXT_CUSTOM:
        case LTXT_CUSTOM_TABULAR:
        case DND:
            exerciseContentViewController = [[Exercise_LTXT_ViewController2 alloc] init];
            break;
            
        case SCR:
            exerciseContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SCR"];
            break;
            
        case SNAKE:
            exerciseContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SNAKE"];
            break;
            
        case MATCHER:
            exerciseContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MATCHER"];
            break;
            
        case MCH:
            exerciseContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MCH"];
            break;
            
        default:
            break;
    }
    
    exerciseContentViewController.exercise = self.exercise;
    
    [self addChildViewController:exerciseContentViewController];
    
    //    exerciseContentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    //    [self.exerciseContainerView setFrameHeight:exerciseContentViewController.view.frame.size.height];
    
    
    UIView* contentView = exerciseContentViewController.view;
    
    
    if (exerciseContentViewController.hasError) {
        
        ErrorViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Error"];
        
        contentView = vc.view;
        
        [vc setErrorDescription:exerciseContentViewController.errorDescription];
        
    }
    
    
    [self.exerciseContainerView addSubview:contentView];
    
    
    [self.exerciseContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|"
                                                                                       options:0
                                                                                       metrics:@{}
                                                                                         views:NSDictionaryOfVariableBindings(contentView)]];
    
    [self.exerciseContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|"
                                                                                       options:0
                                                                                       metrics:@{}
                                                                                         views:NSDictionaryOfVariableBindings(contentView)]];




//    NSLayoutConstraint* con = [NSLayoutConstraint constraintWithItem:self.exerciseContainerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:exerciseContentViewController.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//
//    con.priority = 500;
    
//    [self.exerciseContainerView addConstraint:con];

}




- (IBAction) actionContentTap {

    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}


- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
