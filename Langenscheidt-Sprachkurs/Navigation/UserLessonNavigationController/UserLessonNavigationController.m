//
//  UserLessonNavigationController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "UserLessonNavigationController.h"
#import "PearlViewController.h"
#import "UserProgressManager.h"


@implementation UserLessonNavigationController

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self _update];
    
}


- (void) _update {
    
    PearlViewController* controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Pearl Menu"];
    _currentLesson = [[UserProgressManager instance] currentUserLesson];
    controller.lesson = _currentLesson;
    
    [self setViewControllers:@[controller] animated:NO];
    
    UIView* theView = controller.view;
    controller.navigationItem.title = @"Deine Lektion";

}


- (void) updateIfNeeded {
    
    Lesson* newLesson = [[UserProgressManager instance] currentUserLesson];
    
    if (newLesson.id != _currentLesson.id) {
        
        [self _update];
    }
}

@end
