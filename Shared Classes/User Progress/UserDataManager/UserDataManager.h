//
//  UserDataManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataManager.h"

#import "UserCourse.h"
#import "UserLesson.h"
#import "UserPearl.h"
#import "UserExerciseCluster.h"
#import "UserExerciseClusterEvent.h"

#import "ContentDataManager.h"


@interface UserDataManager : NSObject {
    
}

@property (nonatomic, readonly) DataManager* dataManager;


+ (id) instance;



#pragma mark - Score

- (NSInteger) scoreForLanguage;

- (NSInteger) scoreForCourse:(Course*) course;

- (NSInteger) scoreForLesson:(Lesson*) lesson;

- (NSInteger) scoreForPearl:(Pearl*) pearl;

- (void) increaseScore:(NSInteger) score forExerciseCluster:(ExerciseCluster*) exerciseCluster;



#pragma mark - Number of solved lessons, pearls, exerciseClusters

- (NSInteger) numberOfSolvedLessonsForCourse:(Course*) course;

- (NSInteger) numberOfSolvedPearlsForLesson:(Lesson*) lesson;

- (NSInteger) numberOfSolvedExerciseClustersForCourse:(Course*) course;

- (NSInteger) numberOfSolvedExerciseClustersForPearl:(Pearl*) pearl;

- (BOOL) isLessonNewForCurrentRun:(Lesson*) lesson;

- (BOOL) isCourseNewForCurrentRun:(Course*) course;

- (NSInteger) numberOfAvailableExerciseClustersForPearl:(Pearl*) pearl;


#pragma mark - Run

- (NSInteger) runForLesson:(Lesson*) lesson;

- (NSInteger) runForExerciseCluster:(ExerciseCluster*) exerciseCluster;

- (void) increaseRunForLesson:(Lesson*) lesson;



#pragma mark - ExerciseClusterEvent

- (void) addExerciseClusterEventWithScore:(NSInteger) score maxScore:(NSInteger) maxScore forExerciseCluster:(ExerciseCluster*) exerciseCluster;

- (NSArray*) userExerciseClusterEventsForCurrentRunForPearl:(Pearl*) pearl latest:(BOOL) latest;



#pragma mark - Other

- (UserExerciseCluster*) exerciseClusterWithID:(int32_t) clusterID forPearl:(Pearl*) pearl;

- (ExerciseCluster*) exerciseClusterForUserExerciseCluster:(UserExerciseCluster*) userExerciseCluster;

- (NSInteger) numberOfAvailableExerciseClustersForPearl:(Pearl*) pearl;

- (ExerciseCluster*) mostRecentExerciseClusterForUserLessonForCurrentRun:(Lesson*) lesson;

- (ExerciseCluster*) mostRecentExerciseClusterForPearlForCurrentRun:(Pearl*) pearl;



#pragma mark - Reset

- (void) reset;


#pragma mark - Current User Lesson

- (Lesson*) currentUserLesson;

- (void) setCurrentUserLesson:(Lesson*) lesson;

    
    
    
#pragma mark - TEMP

- (NSArray*) userExerciseClusterEvents;


//- (void) populateForLanguage;

- (void) populateStructureAndTeaserContent;

- (void) populateForCourse:(Course*) course;

@end
