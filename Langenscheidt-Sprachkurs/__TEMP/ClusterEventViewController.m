//
//  ClusterEventViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ClusterEventViewController.h"
#import "UserDataManager.h"
#import "NSArray+Extensions.h"
#import "ClusterEventCell.h"
#import "UserExerciseClusterEvent.h"
#import "PearlTitle.h"
#import "UILabel+HTML.h"
#import "ExerciseTypes.h"


@implementation ClusterEventViewController


- (id) init {
    
    self = [super initWithStyle:UITableViewStylePlain];

    [self _loadData];
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"Übungs-Events";
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(_reload)
                  forControlEvents:UIControlEventValueChanged];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ClusterEventCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    
}


- (void) _loadData  {
    
    _clusterEvents = [[[UserDataManager instance] userExerciseClusterEvents] reversedArray];
}


- (void) _reload {
    
    [self _loadData];
    
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _clusterEvents.count;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 83;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserExerciseClusterEvent* event = _clusterEvents[indexPath.row];
    ExerciseCluster* exerciseCluster = [[UserDataManager instance] exerciseClusterForUserExerciseCluster:event.cluster];
    
    ClusterEventCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    // date
    NSTimeInterval dateInterval = event.date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd.MM.yyyy '-' HH:mm:ss";
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:dateInterval];
    cell.dateLabel.text = [formatter stringFromDate:date];
    
    Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:exerciseCluster];
    
    // course title
    cell.courseLabel.text = pearl.lesson.course.title;
    
    // lesson title
    cell.lessonLabel.text = pearl.lesson.title;
    
    // pearl title
    cell.pearlLabel.text = [PearlTitle titleForPearl:pearl];
    [cell.pearlLabel parseHTML];
    
    // score
    cell.scoreLabel.text = [NSString stringWithFormat:@"%d/%d Punkte", event.score, event.maxScore];
    
    // run
    cell.runLabel.text = [NSString stringWithFormat:@"%d. Run", event.run];
    
    // clusterID
    cell.clusterLabel.text = [NSString stringWithFormat:@"ID: %d", exerciseCluster.id];
    
    // exercise type
    NSString* typeString = nil;
    if (exerciseCluster.exercises.count > 1) {
        typeString = [NSString stringWithFormat:@"(multiple, %ld)", exerciseCluster.exercises.count];
    }
    else {
        Exercise* exercise = exerciseCluster.exercises.anyObject;
        typeString = [ExerciseTypes shortStringForExerciseType:exercise.type];
    }
    cell.typeLabel.text = typeString;
    
    
    return cell;
}



@end
