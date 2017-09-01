//
//  AppDelegate.m
//  DialogTest1
//
//  Created by Stefan Ueter on 04.03.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "AppDelegate.h"
#import "ExerciseNavigationController.h"
#import "ContentDataManager.h"








@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

//    [self _playSpecificDialog];
    
    [self _playSpecificDialogWithNarrator];
    
    
    return YES;
}


- (void) _playSpecificDialogWithNarrator {

    NSArray* dialogs = [self _dialogsWithNarrator];
    
    [self _printDialogs:dialogs];
    
    Exercise* exercise = dialogs[0];
    
    [self _playExercise:exercise];
}


- (void) _printDialogs:(NSArray*) dialogs {

    for (Exercise* dialog in dialogs) {
        
        NSLog(@"Dialog (course: %d - '%@',\tlesson: %d - '%@')",
              [[[[[dialog cluster] pearl] lesson] course] id],
              dialog.cluster.pearl.lesson.course.title,
              [[[[dialog cluster] pearl] lesson] id],
              dialog.cluster.pearl.lesson.title);
    }
}


- (NSArray*) _dialogsWithNarrator {
    
    NSMutableArray* dialogsWithNarrator = [NSMutableArray array];
    
    // loop courses

    NSArray* courses = [[ContentDataManager instance] courses];

    for (Course* course in courses) {
        
        // loop lessons
        
        NSArray* lessons = [[ContentDataManager instance] lessonsForCourse:course withType:DIALOG];
        
        for (Lesson* lesson in lessons) {
            
            // loop pearls
            
            NSArray* pearls = [[ContentDataManager instance] pearlsForLesson:lesson withType:DIALOG];
            
            for (Pearl* pearl in pearls) {
                
                // loop exercises
                
                NSArray* exercises = [[ContentDataManager instance] exercisesForPearl:pearl withType:DIALOG];
                
                for (Exercise* exercise in exercises) {
                    
                    BOOL hasNarrator = NO;
                    
                    
                    // loop lines
                    
                    NSArray* dialogLines = [[ContentDataManager instance] dialogLinesForExercise:exercise];
                    
                    for (DialogLine* dialogLine in dialogLines) {
                        
                        // check if line has no audio range
                        
                        if (dialogLine.audioRange.length == 0 || dialogLine.speaker.length == 0) {
                            
                            // add to array, break loop to next exercise
                            
                            hasNarrator = YES;
                            break;
                        }
                    }
                    
                    
                    if (hasNarrator) {
                        
                        [dialogsWithNarrator addObject:exercise];
                    }
                }
            }
            
        }
    }
    
    return dialogsWithNarrator;
}


- (void) _playSpecificDialog {
    
    Course* course = [[ContentDataManager instance] courses][0];
    Lesson* lesson = [[ContentDataManager instance] lessonsForCourse:course withType:DIALOG][0];
    Pearl* pearl = [[ContentDataManager instance] pearlsForLesson:lesson withType:DIALOG][0];
    Exercise* exercise = [[ContentDataManager instance] exercisesForPearl:pearl withType:DIALOG][0];
    
    [self _playExercise:exercise];
}


- (void) _playExercise:(Exercise*) exercise {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"exercises" bundle:[NSBundle mainBundle]];
    ExerciseNavigationController* controller = [storyboard instantiateViewControllerWithIdentifier:@"Navigation Controller"];
    controller.exercise = exercise;
    
    [self.window setRootViewController:controller];

}

@end
