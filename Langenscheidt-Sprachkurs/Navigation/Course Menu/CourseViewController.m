//
//  CourseViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "CourseViewController.h"
#import "CourseMenuCell.h"
#import "ContentDataManager.h"
#import "TableViewHeader.h"
#import "LessonViewController.h"
#import "SettingsManager.h"
#import "UserProgressManager.h"

#import "Onboarding1ViewController.h"


#import "LTracker.h"



#define TITLE       @"Kurse"

#define LESSON_COUNT_FORMAT         @"%ld Lektionen"


@implementation CourseViewController

@synthesize header;
@synthesize pointsLabel;


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    _courses = [[ContentDataManager instance] courses];
    
    return self;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showLessonsForCourse"]) {
    
        Course* theCourse = nil;
        
        if ([sender isKindOfClass:[Course class]]) {
            
            theCourse = (Course*)sender;
        }
        else {
            
            theCourse = ((CourseMenuCell*)sender).course;
        }
        
        LessonViewController* controller = (LessonViewController*)segue.destinationViewController;
        controller.course = theCourse;
    }
}


#pragma mark - View, Layout, Constraints

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    GATrackingSetScreenName(@"Kursübersicht");
    GATrackingSetTrackScreenViews(YES);
    LTrackerSetContentPath(@"Englisch");
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = TITLE;
    
//    self.parallaxingRatio = 0.5;
//    self.parallaxingHeaderCap = 89 - 3;
    
    self.titleLabel.text = @"Englisch";
    
    

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


#pragma mark - Update UI

- (void) updateUI {
    
//    [self _updateScoreAsync];
    [self _updateScoreSync];
    
    if (_cellsLoaded) {
        
        [self _updateCells];
    }
}


- (void) _updateCells {
    
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    
    for (int i = 0; i < numberOfRows; ++i) {
        
        CourseMenuCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [cell updateProgressSync];
    }
}




#pragma mark - Table View


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _courses.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CourseMenuCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    Course* course = _courses[indexPath.row];
    
    NSInteger number = [[[ContentDataManager instance] lessonsForCourse:course] count];
    
    cell.titleLabel.text = course.title;
    cell.numberLabel.text = [NSString stringWithFormat:LESSON_COUNT_FORMAT, number];
    cell.course = course;
    
    // image
    
    NSString* photoFile = course.imageFile;
    photoFile = [photoFile stringByDeletingPathExtension];
    photoFile = [[photoFile stringByAppendingString:@"_small"] stringByAppendingPathExtension:@"jpg"];
    NSString* photosFolder = [[NSBundle mainBundle] pathForResource:@"Menu Photos" ofType:nil];
    NSString* fullPath = [photosFolder stringByAppendingPathComponent:photoFile];
    NSData* imageData = [NSData dataWithContentsOfFile:fullPath];
    UIImage* image = [UIImage imageWithData:imageData scale:2.0f];
    
    cell.imageView.image = image;
    
    //
    
    [cell updateProgressSync];

    
    _cellsLoaded = YES;
    
    
    return cell;
}





#pragma mark - Score

- (void) _updateScoreSync {
    
   NSInteger score = [[UserProgressManager instance] scoreForLanguage];

    self.pointsLabel.text = [NSString stringWithFormat:@"%ld", score];
}


//- (void) _updateScoreAsync {
//
//    __weak CourseViewController* weakSelf = self;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//
//        NSInteger score = [[UserDataManager instance] scoreForLanguage];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            weakSelf.pointsLabel.text = [NSString stringWithFormat:@"%ld", score];
//        });
//    });
//    
//    
//}



#pragma mark - Open Lesson Menu

- (void) pushLessonMenuForCourse:(Course*) course {   // not animated
    
//    [self performSegueWithIdentifier:@"showLessonsForCourse" sender:course];
    
    LessonViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"Lesson Menu"];
    controller.course = course;
    
    [self.navigationController pushViewController:controller animated:NO];
}


@end
