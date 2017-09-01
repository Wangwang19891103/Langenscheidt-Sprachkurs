//
//  LessonViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "LessonViewController.h"
#import "ContentDataManager.h"
#import "LessonCell.h"
#import "Lesson.h"
#import "PearlViewController.h"


@implementation LessonViewController

@synthesize course;
@synthesize filterType;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    return self;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowPearls"]) {
        
        PearlViewController* controller = (PearlViewController*)segue.destinationViewController;
        LessonCell* cell = (LessonCell*)sender;
        controller.filterType = self.filterType;
        controller.lesson = cell.lesson;
    }
}


- (void) setCourse:(Course *)p_course {
    
    course = p_course;
    
    if (self.filterType != NONE) {
        
        _lessons = [[ContentDataManager instance] lessonsForCourse:course withType:self.filterType];
    }
    else {

        _lessons = [[ContentDataManager instance] lessonsForCourse:course];
    }
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    if (self.filterType != NONE) {

        self.navigationItem.title = [NSString stringWithFormat:@"%@ (gefiltert)", course.title];
    }
    else {

        self.navigationItem.title = course.title;
    }
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _lessons.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LessonCell* cell = [tableView dequeueReusableCellWithIdentifier:@"LessonCell"];
    Lesson* lesson = _lessons[indexPath.row];
    cell.titleLabel.text = lesson.title;
    cell.lesson = lesson;
    
    return cell;
}

@end
