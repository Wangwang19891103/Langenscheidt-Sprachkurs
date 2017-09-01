//
//  ExercisesPageViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ExercisesPageViewController2.h"
#import "ContentDataManager.h"
#import "ExerciseDataViewController.h"
#import "PearlTitle.h"
#import "ExerciseTypes.h"
#import "ExerciseDictionary.h"

#import "ExerciseViewController.h"
//#import "ABCController.h"
#import "ExerciseNavigationController.h"


@implementation ExercisesPageViewController

@synthesize pearl;
@synthesize filterType;


- (id) initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
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
 
    self.dataSource = self;
    self.delegate = self;
    
    ExerciseNavigationController* controller = [self viewControllerAtIndex:0];
    controller.index = 0;
    [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self _updateNavigationBarForController:controller];
    
//    [self _addContentTapRecognizer];
}


- (void) _addContentTapRecognizer {
    
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleContentTap:)];
    
    [self.view addGestureRecognizer:recognizer];
}


- (void) _handleContentTap:(UIGestureRecognizer*) recognizer {
    
    NSLog(@"content tap");
    
    [self.view endEditing:YES];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
//    NSLog(@"constraints: %@", self.view.constraints);
    
}


- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    ExerciseNavigationController* topController = (ExerciseNavigationController*)viewController;
    NSInteger index = topController.index;
    
    if (index >= _exercises.count - 1) {
        
        return nil;
    }
    else {
        
        return [self viewControllerAtIndex:index + 1];
    }
}


- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    ExerciseNavigationController* topController = (ExerciseNavigationController*)viewController;
    NSInteger index = topController.index;
    
    if (index <= 0) {
        
        return nil;
    }
    else {
        
        return [self viewControllerAtIndex:index - 1];
    }
}


//- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//    
//    return _exercises.count;
//}
//
//
//- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
//    
//    return 0;
//}


//- (void) pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
//    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//}


- (void) pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    
    [self _updateNavigationBarForController:pendingViewControllers[0]];
}


- (void) _updateNavigationBarForController:(ExerciseNavigationController*) controller {
    
    controller.navigationBar.totalPositions = _exercises.count;
    controller.navigationBar.currentPosition = controller.index + 1;
}


- (ExerciseNavigationController*) viewControllerAtIndex:(NSInteger) index {
    
    ExerciseNavigationController* controller = [_pages objectForKey:@(index)];
    
    if (!controller) {
        
        Exercise* exercise = _exercises[index];
        controller = [self viewControllerForExercise:exercise];
        controller.index = index;
//        controller.navigationBar.currentPosition = index + 1;
//        controller.navigationBar.totalPositions = _exercises.count;
        
        [_pages setObject:controller forKey:@(index)];
        
        NSLog(@"instantiating page controller with index %ld", index);
    }
    
    return controller;
}


- (ExerciseNavigationController*) viewControllerForExercise:(Exercise*) exercise {

//    NSMutableArray* viewControllers = [NSMutableArray array];
    
    ExerciseNavigationController* controller = [[UIStoryboard storyboardWithName:@"exercises" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Navigation Controller"];
    controller.exercise = exercise;
    
//    [viewControllers addObject:controller];
    
    return controller;
}




@end
