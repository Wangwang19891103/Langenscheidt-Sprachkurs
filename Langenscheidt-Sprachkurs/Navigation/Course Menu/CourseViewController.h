//
//  CourseViewController.h
//  Langenscheidt-Sprachkurs
///
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "MenuViewController.h"
#import "Course.h"
#import "TableViewHeader.h"



@interface CourseViewController : MenuViewController {
    
    NSArray* _courses;
    
    BOOL _cellsLoaded;
}

@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (void) pushLessonMenuForCourse:(Course*) course;


@end
