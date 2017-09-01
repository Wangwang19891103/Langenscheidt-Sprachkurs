//
//  CourseViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 29.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExerciseTypes.h"

@interface CourseViewController : UITableViewController <UITableViewDataSource> {
    
    NSArray* _courses;
}

@property (nonatomic, assign) ExerciseType filterType;

@end


