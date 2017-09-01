//
//  ExerciseViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "ExerciseContentViewController.h"


@interface ExerciseViewController2: UIViewController

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) Exercise* exercise;


// remove later
@property (nonatomic, strong) IBOutlet UILabel* idLabel;

@property (nonatomic, strong) IBOutlet UILabel* typeLabel;
// ---

@property (nonatomic, strong) ExerciseContentViewController* exerciseContentViewController;

@property (nonatomic, strong) IBOutlet UIView* exerciseContainerView;

@property (nonatomic, strong) IBOutlet UIView* bottomDummyView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomDummyHeightConstraint;

- (id) initWithExercise:(Exercise*) exercise;

- (IBAction) actionContentTap;

@end
