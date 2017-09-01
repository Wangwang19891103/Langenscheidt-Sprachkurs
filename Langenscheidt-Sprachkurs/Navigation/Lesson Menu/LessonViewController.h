//
//  CourseViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Course.h"
#import "ProgressBar.h"
#import "TableViewHeader.h"
#import "MenuViewController.h"


@interface LessonViewController : MenuViewController {
    
    NSArray* _lessons;
}

@property (nonatomic, assign) Course* course;

@property (strong, nonatomic) IBOutlet TableViewHeader *header;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfLessonsLabel;
@property (strong, nonatomic) IBOutlet ProgressBar *lessonProgressBar;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

- (void) pushPearlMenuForLesson:(Lesson*) lesson;

    
@end
