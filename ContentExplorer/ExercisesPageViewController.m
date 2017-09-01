//
//  ExercisesPageViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ExercisesPageViewController.h"
#import "ContentDataManager.h"
#import "ExerciseDataViewController.h"
#import "PearlTitle.h"
#import "ExerciseTypes.h"

#import "ExerciseViewController2.h"
#import "Exercise_LTXT_ViewController2.h"


@implementation ExercisesPageViewController

@synthesize pearl;
@synthesize filterType;


- (id) initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    self.dataSource = self;
    _pages = [NSMutableDictionary dictionary];
    
    return self;
}


- (void) setPearl:(Pearl *)p_pearl {
    
    pearl = p_pearl;
    
    if (self.filterType != NONE) {
        
        _exercises = [[ContentDataManager instance] exercisesForPearl:pearl withType:self.filterType];
    }
    else {
        
        _exercises = [[ContentDataManager instance] exercisesForPearl:pearl];
    }
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    ExerciseViewController2* controller = [self viewControllerAtIndex:0];
    controller.index = 0;
    [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    if (self.filterType != NONE) {
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (gefiltert)", [PearlTitle titleForPearl:pearl]];
    }
    else {
        
        self.navigationItem.title = [PearlTitle titleForPearl:pearl];

    }
}


- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    ExerciseViewController2* topController = (ExerciseViewController2*)viewController;
    NSInteger index = topController.index;
    
    if (index >= _exercises.count - 1) {
        
        return nil;
    }
    else {
        
        return [self viewControllerAtIndex:index + 1];
    }
}


- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    ExerciseViewController2* topController = (ExerciseViewController2*)viewController;
    NSInteger index = topController.index;
    
    if (index <= 0) {
        
        return nil;
    }
    else {
        
        return [self viewControllerAtIndex:index - 1];
    }
}


- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return _exercises.count;
}


- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}


- (ExerciseViewController2*) viewControllerAtIndex:(NSInteger) index {
    
    ExerciseViewController2* controller = [_pages objectForKey:@(index)];
    
    if (!controller) {
        
        Exercise* exercise = _exercises[index];
        controller = [self viewControllerForExercise:exercise];
        controller.index = index;
        
        [_pages setObject:controller forKey:@(index)];
        
        NSLog(@"instantiating page controller with index %ld", index);
    }
    
    return controller;
}


- (ExerciseViewController2*) viewControllerForExercise:(Exercise*) exercise {
    
    ExerciseViewController2* controller = nil;
    
    switch (exercise.type) {

        case LTXT_STANDARD:
        case LTXT_STANDARD_TABULAR:
        case LTXT_CUSTOM:
        case LTXT_CUSTOM_TABULAR:
        case DND:
        case SCR:
        case SNAKE:
        case MATCHER:
        case MCH:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Exercise"];
            break;

        default:
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ExercisePage"];
            break;
    }
    
    controller.exercise = exercise;
    
    return controller;
}

@end
