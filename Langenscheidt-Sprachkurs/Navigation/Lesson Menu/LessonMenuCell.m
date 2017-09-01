//
//  CourseMenuCell.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "LessonMenuCell.h"
#import "UserProgressManager.h"
#import "ContentManager.h"


#define IMAGE_NAME_NEW      @"Lesson Menu Cell Arrow Empty"
#define IMAGE_NAME_STARTED  @"Lesson Menu Cell Arrow Half"
#define IMAGE_NAME_COMPLETE @"Lesson Menu Cell Arrow Full"





@implementation LessonMenuCell

@synthesize titleLabel;
@synthesize lesson;


- (void) prepareForReuse {
    
    self.arrowImageView.image = [UIImage imageNamed:IMAGE_NAME_NEW];
}


- (void) updateProgressSync {

    ContentManagerContentAvailabilityStatus contentAvailabilityStatus = [[ContentManager instance] contentAvailabilityStatusForLesson:self.lesson];
    
//    BOOL contentInstalled = [[ContentManager instance] contentInstalledForLesson:self.lesson];
    
    if (contentAvailabilityStatus == ContentManagerContentAvailabilityStatusNotInstalled) {
        
        self.arrowImageView.hidden = YES;
        self.downloadImageView.hidden = NO;
        self.lockedImageView.hidden = YES;
    }
    else if (contentAvailabilityStatus == ContentManagerContentAvailabilityStatusNoSubscription) {
        
        self.arrowImageView.hidden = YES;
        self.downloadImageView.hidden = YES;
        self.lockedImageView.hidden = NO;
    }
    else {
        
        UserProgressLessonCompletionStatus completionStatus = [[UserProgressManager instance] completionStatusForLesson:self.lesson];
        
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
        
        self.arrowImageView.hidden = NO;
        self.downloadImageView.hidden = YES;
        self.lockedImageView.hidden = YES;
    }
    
}


//- (void) updateProgressAsync {
//
//    __weak LessonMenuCell* weakSelf = self;
//    
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        
//        UserProgressLessonCompletionStatus completionStatus = [[UserProgressManager instance] completionStatusForLesson:self.lesson];
//        
//        NSString* imageName = nil;
//        
//        switch (completionStatus) {
//                
//            case UserProgressLessonCompletionStatusNew:
//                imageName = IMAGE_NAME_NEW;
//                break;
//                
//            case UserProgressLessonCompletionStatusStarted:
//                imageName = IMAGE_NAME_STARTED;
//                break;
//                
//            case UserProgressLessonCompletionStatusCompleted:
//                imageName = IMAGE_NAME_COMPLETE;
//                break;
//                
//            default:
//                break;
//        }
//        
//        __block UIImage* image = [UIImage imageNamed:imageName];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            weakSelf.arrowImageView.image = image;
//        });
//        
//        
//    });
//}


@end
