//
//  UserLessonNavigationController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NavigationController.h"
#import "Lesson.h"


@interface UserLessonNavigationController : NavigationController {
    
    Lesson* _currentLesson;
}


- (void) updateIfNeeded;

@end
