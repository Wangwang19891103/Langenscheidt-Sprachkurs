//
//  CourseViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "LessonViewController.h"
#import "LessonMenuCell.h"
#import "ContentDataManager.h"
#import "TableViewHeader.h"
#import "PearlViewController.h"
#import "UserProgressManager.h"

#import "SettingsManager.h"


#import "LTracker.h"
#import "ScreenName.h"


#define PARALLAXING_HEADER_CAP          120

#define NUMBER_OF_LESSONS_LABEL_FORMAT      @"%ld/%ld Lektionen"

#define DUMMY_NUMBER_OF_SOLVED_LESSONS      8
#define DUMMY_NUMBER_COURSE_POINTS      125

@implementation LessonViewController

@synthesize header;
@synthesize course;
@synthesize pointsLabel;
@synthesize numberOfLessonsLabel;
@synthesize lessonProgressBar;


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    return self;
}


- (void) setCourse:(Course *)p_course {
    
    course = p_course;
    
    _lessons = [[ContentDataManager instance] lessonsForCourse:self.course];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPearlsForLesson"]) {

        Lesson* theLesson = ((LessonMenuCell*)sender).lesson;
        PearlViewController* controller = (PearlViewController*)segue.destinationViewController;
        controller.lesson = theLesson;
        
    }
}


#pragma mark - View, Layout, Constraints

- (void) viewDidLoad {
    
    [super viewDidLoad];

    
    GATrackingSetScreenName(@"Lektions-Menü");
    GATrackingSetTrackScreenViews(YES);
    LTrackerSetContentPath([ScreenName nameForCourse:self.course]);
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"Lektionen";
    
//    self.parallaxingHeaderCap = PARALLAXING_HEADER_CAP;
//    self.parallaxingRatio = 0.5;
//    self.parallaxingHeaderCap = 89 - 3;

    
    [self _setupImage];
    
//    [self _updateScoreSync];
    
    self.titleLabel.text = self.course.title;

}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self updateUI];
    
    self.parallaxingHeaderCap = 75.0;
    self.parallaxingRatio = 0.5;

}


- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];

    if (!self.tableView.tableHeaderView) {
        
        self.tableView.tableHeaderView = self.header;
    }
    
}



#pragma mark - updateUI

- (void) updateUI {

//    [self _updateScoreAsync];
    [self _updateScoreSync];
    
    [self _updateCells];
}



- (void) _updateCells {
    
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    
    for (int i = 0; i < numberOfRows; ++i) {
        
        LessonMenuCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [cell updateProgressSync];
    }
}




#pragma mark - Score

- (void) _updateScoreSync {
    
    NSInteger score = [[UserProgressManager instance] scoreForCourse:self.course];
    NSInteger solvedLessons = [[UserProgressManager instance] numberOfSolvedLessonsForCourse:self.course];
    CGFloat lessonProgressPercentage = (solvedLessons / (CGFloat)_lessons.count);
    
    self.pointsLabel.text = [NSString stringWithFormat:@"%ld", score];
    self.lessonProgressBar.percentage = lessonProgressPercentage;
    self.numberOfLessonsLabel.text = [NSString stringWithFormat:NUMBER_OF_LESSONS_LABEL_FORMAT, solvedLessons, (unsigned long)_lessons.count];
}


//- (void) _updateScoreAsync {
//    
//    __weak LessonViewController* weakSelf = self;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        
//        NSInteger score = [[UserDataManager instance] scoreForCourse:weakSelf.course];
//        NSInteger solvedLessons = [[UserDataManager instance] numberOfSolvedLessonsForCourse:weakSelf.course];
//        CGFloat lessonProgressPercentage = (solvedLessons / (CGFloat)_lessons.count);
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            weakSelf.pointsLabel.text = [NSString stringWithFormat:@"%ld", score];
//            weakSelf.lessonProgressBar.percentage = lessonProgressPercentage;
//            weakSelf.numberOfLessonsLabel.text = [NSString stringWithFormat:NUMBER_OF_LESSONS_LABEL_FORMAT, solvedLessons, (unsigned long)_lessons.count];
//            
//        });
//    });
//}





- (void) _setupImage {
    
    NSString* photoFile = self.course.imageFile;
    photoFile = [photoFile stringByDeletingPathExtension];
    photoFile = [[photoFile stringByAppendingString:@""] stringByAppendingPathExtension:@"jpg"];
    NSString* photosFolder = [[NSBundle mainBundle] pathForResource:@"Menu Photos" ofType:nil];
    NSString* fullPath = [photosFolder stringByAppendingPathComponent:photoFile];
    UIImage* image = [UIImage imageWithContentsOfFile:fullPath];
    
    self.imageView.image = image;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _lessons.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LessonMenuCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    Lesson* lesson = _lessons[indexPath.row];
    
    cell.titleLabel.text = lesson.title;
    cell.lesson = lesson;
    
    [cell updateProgressSync];
    
    return cell;
}











//#pragma mark - Update Current User Lesson
//
//- (void) _updateCurrentUserLessonWithLesson:(Lesson*) lesson {
//    
//    NSNumber* devBrowseSetsUserLesson = [[SettingsManager instanceNamed:@"dev"] valueForKey:@"browseSetsUserLesson"];
//    
//    if (devBrowseSetsUserLesson) {
//        
//        if ([devBrowseSetsUserLesson boolValue]) {
//            
//            [[UserProgressManager instance] setCurrentUserLesson:lesson];
//        }
//    }
//    else {
//        
//        [[UserProgressManager instance] setCurrentUserLesson:lesson];
//    }
//    
//}



#pragma mark - Open Pearl Menu

- (void) pushPearlMenuForLesson:(Lesson*) lesson {  // not animated
    
//    [self performSegueWithIdentifier:@"showPearlsForLesson" sender:lesson];
    
    PearlViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Pearl Menu"];
    controller.lesson = lesson;
    
    [self.navigationController pushViewController:controller animated:NO];
}



@end
