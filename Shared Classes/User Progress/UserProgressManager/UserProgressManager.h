//
//  UserProgressManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentDataManager.h"
#import "UserDataManager.h"
@import UIKit;



typedef NS_ENUM(NSInteger, UserProgressLessonCompletionStatus) {
    UserProgressLessonCompletionStatusNew,
    UserProgressLessonCompletionStatusStarted,
    UserProgressLessonCompletionStatusCompleted
};



@interface UserProgressManager : NSObject {
    
    ContentDataManager* _contentDataManager;
    UserDataManager* _userDataManager;
    
    ExerciseCluster* _activeExerciseCluster;
    NSMutableDictionary* _activeExerciseClusterDict;
}


+ (id) instance;




extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));






#pragma mark - Reset User Data

- (void) resetUserDataWithParentViewController:(UIViewController*) parentController;


#pragma mark - Progress

- (float) progressForPearl:(Pearl*) pearl;



#pragma mark - ExerciseClusters / Exercises / Score

- (NSInteger) scoreForLanguage;

- (NSInteger) scoreForCourse:(Course*) course;

- (NSInteger) scoreForLesson:(Lesson*) lesson;

- (NSInteger) scoreForPearl:(Pearl*) pearl;

- (void) setActiveExerciseClusterIfNew:(ExerciseCluster*) exerciseCluster;

//- (void) setActiveExerciseClusterIfNew:(ExerciseCluster *)exerciseCluster;

//- (BOOL) isNewExerciseCluster:(ExerciseCluster*) exerciseCluster;

//- (void) setNewActiveExerciseCluster:(ExerciseCluster*) exerciseCluster;

- (void) setScore:(NSInteger) score ofMaxScore:(NSInteger) maxScore forExercise:(Exercise*) exercise;

//- (void) populateWithAutogeneratedExerciseWithClusterIDIfNeeded:(int32_t) exerciseClusterID inPearl:(Pearl*) pearl;

- (void) finalScoreForActivePearlScore:(NSInteger*) score maxScore:(NSInteger*) maxScore;


#pragma mark - Next Pearl

- (Pearl*) nextPearlForPearl:(Pearl*) pearl;

- (ExerciseCluster*) nextIncompleteExerciseClusterForPearlInsideSamePearl:(Pearl*) pearl;


#pragma mark - Next incomplete pearl / exercise cluster in lesson

- (ExerciseCluster*) nextIncompleteExerciseClusterForLesson222:(Lesson*) lesson;


#pragma mark - Your Lesson (Deine Lektion)

- (Lesson*) currentUserLesson;

- (void) setCurrentUserLesson:(Lesson*) lesson;



#pragma mark - Start next run for lesson

- (void) startNextRunForLesson:(Lesson*) lesson;



#pragma mark - Completion Status for Lesson

- (UserProgressLessonCompletionStatus) completionStatusForLesson:(Lesson*) lesson;

- (UserProgressLessonCompletionStatus) completionStatusForCourse:(Course*) course;


#pragma mark - Other

- (NSInteger) numberOfExercisesBeforeExerciseCluster:(ExerciseCluster*) exerciseCluster;

- (NSInteger) numberOfSolvedLessonsForCourse:(Course*) course;

//- (NSInteger) numberOfsolvedExerciseClustersForLesson:(Lesson*) lesson;

- (NSInteger) numberOfSolvedPearlsForLesson:(Lesson *)lesson;

@end
