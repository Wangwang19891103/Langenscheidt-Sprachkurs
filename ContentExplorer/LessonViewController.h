//
//  LessonViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Course.h"
#import "ExerciseTypes.h"


@interface LessonViewController : UITableViewController <UITableViewDataSource> {
    
    NSArray* _lessons;
}

@property (nonatomic, assign) Course* course;

@property (nonatomic, assign) ExerciseType filterType;

@end
