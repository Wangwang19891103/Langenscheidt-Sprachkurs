//
//  CourseMenuCell.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "CourseMenuCell.h"
#import "UserProgressManager.h"


#define IMAGE_NAME_NEW      @"Lesson Menu Cell Arrow Empty"
#define IMAGE_NAME_STARTED  @"Lesson Menu Cell Arrow Half"
#define IMAGE_NAME_COMPLETE @"Lesson Menu Cell Arrow Full"



@implementation CourseMenuCell

@synthesize titleLabel;
@synthesize numberLabel;
@synthesize course;



- (void) prepareForReuse {
    
    self.arrowImageView.image = [UIImage imageNamed:IMAGE_NAME_NEW];
}


- (void) updateProgressSync {
    
    UserProgressLessonCompletionStatus completionStatus = [[UserProgressManager instance] completionStatusForCourse:self.course];
    
    NSString* imageName = nil;
    
    switch (completionStatus) {
            
        case UserProgressLessonCompletionStatusNew:
            imageName = IMAGE_NAME_NEW;
            break;
            
        case UserProgressLessonCompletionStatusStarted:
            imageName = IMAGE_NAME_STARTED;
            break;
            
        case UserProgressLessonCompletionStatusCompleted:
            imageName = IMAGE_NAME_COMPLETE;
            break;
            
        default:
            break;
    }
    
    UIImage* image = [UIImage imageNamed:imageName];
    
    self.arrowImageView.image = image;
}



@end
