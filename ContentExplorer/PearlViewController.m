//
//  PearlViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "PearlViewController.h"
#import "ContentDataManager.h"
#import "PearlCellVocabulary.h"
#import "PearlCellDialog.h"
#import "PearlCellExercise.h"
#import "PearlTitle.h"
#import "VocabularyViewController.h"
#import "PearlSorter.h"
#import "DialogViewController.h"
#import "PearlCellExercise.h"
#import "ExercisesPageViewController.h"
//#import "DialogViewController2.h"
#import "UILabel+HTML.h"


@implementation PearlViewController

@synthesize lesson;
@synthesize filterType;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    return self;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowVocabularies"]) {
        
        VocabularyViewController* controller = (VocabularyViewController*)segue.destinationViewController;
        PearlCellVocabulary* cell = (PearlCellVocabulary*)sender;
        controller.pearl = cell.pearl;
    }
//    else if ([segue.identifier isEqualToString:@"ShowDialog"]) {
//        
//        DialogViewController2* controller = (DialogViewController2*)segue.destinationViewController;
//        PearlCellDialog* cell = (PearlCellDialog*)sender;
//        controller.pearl = cell.pearl;
//    }
    else if ([segue.identifier isEqualToString:@"showExercise"]) {
        
        ExercisesPageViewController* controller = (ExercisesPageViewController*)segue.destinationViewController;
        PearlCellExercise* cell = (PearlCellExercise*)sender;
        controller.filterType = self.filterType;
        controller.pearl = cell.pearl;
        
//        [self.navigationController setNavigationBarHidden:YES animated:NO];

    }
}


- (void) setLesson:(Lesson *)p_lesson {
    
    lesson = p_lesson;
    
    NSArray* pearls = nil;
    
    if (self.filterType != NONE) {
        
        pearls = [[ContentDataManager instance] pearlsForLesson:lesson withType:self.filterType];
    }
    else {
        
        pearls = [[ContentDataManager instance] pearlsForLesson:lesson];
    }
    
    _pearls = [PearlSorter sortPearls:pearls];
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    if (self.filterType != NONE) {
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (gefiltert)", lesson.title];
    }
    else {
        
        self.navigationItem.title = lesson.title;
    }
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _pearls.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Pearl* pearl = _pearls[indexPath.row];

//    if (pearl.vocabularies.count != 0) {
//        
//        PearlCellVocabulary* cell = [tableView dequeueReusableCellWithIdentifier:@"PearlCellVocabulary"];
//        cell.titleLabel.text = [PearlTitle titleForPearl:pearl];
//        [cell.titleLabel parseHTML];
//        cell.pearl = pearl;
//        
//        return cell;
//    }
//    if (pearl.dialogs.count != 0) {
//        
//        PearlCellDialog* cell = [tableView dequeueReusableCellWithIdentifier:@"PearlCellDialog"];
//        cell.titleLabel.text = [PearlTitle titleForPearl:pearl];
//        [cell.titleLabel parseHTML];
//        cell.pearl = pearl;
//        
//        return cell;
//    }
    if (pearl.exerciseClusters.count != 0) {
        
        PearlCellDialog* cell = [tableView dequeueReusableCellWithIdentifier:@"PearlCellExercise"];
        cell.titleLabel.text = [PearlTitle titleForPearl:pearl];
        [cell.titleLabel parseHTML];
        cell.pearl = pearl;
        
        return cell;
    }
    
    else return nil;
}


@end
