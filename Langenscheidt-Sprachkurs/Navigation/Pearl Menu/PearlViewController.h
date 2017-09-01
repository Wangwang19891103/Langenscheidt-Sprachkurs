//
//  PearlViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 07.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "MenuViewController.h"
#import "Lesson.h"
#import "ProgressBar.h"
#import "UserProgressManager.h"
#import "ContentManager.h"
#import "SubscriptionManager.h"


typedef NS_ENUM(NSInteger, PearlViewControllerTopButtonState) {
    
    PearlViewControllerTopButtonStateNone,
    PearlViewControllerTopButtonStateStart,
    PearlViewControllerTopButtonStateContinue,
    PearlViewControllerTopButtonStateRestart,
    PearlViewControllerTopButtonStateDownload,
    PearlViewControllerTopButtonStateUnlock
};



@interface PearlViewController : MenuViewController <ContentManagerObserver, SubscriptionManagerObserver> {
    
    NSArray* _pearls;
    
    UserProgressLessonCompletionStatus _completionStatus;
    
    PearlViewControllerTopButtonState _topButtonState;
    
    BOOL _viewLoaded;
}

@property (nonatomic, assign) Lesson* lesson;

@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfLessonsLabel;
@property (strong, nonatomic) IBOutlet ProgressBar *lessonProgressBar;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *topButton;


- (void) pushExerciseNavigationControllerForExerciseCluster:(ExerciseCluster*) exerciseCluster withIntroScreen:(BOOL) withIntroScreen;


//- (void) update;

- (IBAction) actionTopButton;

@end

