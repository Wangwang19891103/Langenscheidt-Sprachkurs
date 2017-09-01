//
//  CourseViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 29.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "CourseViewController.h"
#import "ContentDataManager.h"
#import "CourseCell.h"
#import "LessonViewController.h"
#import "DevNewsViewController.h"


@implementation CourseViewController

@synthesize filterType;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    _courses = [[ContentDataManager instance] courses];
    
    return self;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowLessons"]) {
        
        LessonViewController* controller = (LessonViewController*)segue.destinationViewController;
        CourseCell* cell = (CourseCell*)sender;
        controller.filterType = self.filterType;
        controller.course = cell.course;
    }
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    if (self.filterType != NONE) {
        
        self.navigationItem.title = @"Kurse (gefiltert)";
    }
    else {
        
        self.navigationItem.title = @"Kurse";
    }
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.filterType != NONE) {
        
        return _courses.count;
    }
    else {

        return _courses.count + 1;
    }
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _courses.count) {

        CourseCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TypeSelectionCell"];
        cell.titleLabel.text = @"Übungstypen";
        
        return cell;
    }
//    else if (indexPath.row == _courses.count + 1) {
//        
//        CourseCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DevNewsCell"];
//        cell.titleLabel.text = @"Notes";
//        
//        return cell;
//    }
    else {

        CourseCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CourseCell"];
        Course* course = _courses[indexPath.row];
        cell.titleLabel.text = course.title;
        cell.course = course;
        
        return cell;
    }
}

@end


