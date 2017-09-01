//
//  AppDelegate.h
//  ContentSplitter
//
//  Created by Stefan Ueter on 10.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager2.h"
#import "Course.h"
#import "Lesson.h"
#import "Pearl.h"
#import "ExerciseCluster.h"
#import "Exercise.h"
#import "Vocabulary.h"
#import "DialogLine.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    DataManager2* _dataManager;
    
    int _logCounter;
}

@property (strong, nonatomic) UIWindow *window;


@end

