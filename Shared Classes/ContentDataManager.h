//
//  ContentDataManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 29.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager2.h"
#import "Course.h"
#import "Pearl.h"
#import "ExerciseTypes.h"
#import "Vocabulary.h"
#import "Exercise.h"
#import "ExerciseLine.h"
#import "DialogLine.h"
#import "Lesson.h"
#import "ExerciseCluster.h"


@interface ContentDataManager : NSObject {
    
}

@property (nonatomic, readonly) DataManager2* dataManager;


+ (instancetype) instance;

- (void) reloadCourseStores;

- (NSArray*) courses;

- (Course*) courseForVocabulary:(Vocabulary*) vocabulary;

- (Course*) courseForExerciseCluster:(ExerciseCluster*) exerciseCluster;

- (NSArray*) lessonsForCourse:(Course*) course;

- (NSArray*) allLessons;

- (NSArray*) lessonsForCourse:(Course *)course withType:(ExerciseType) type;

- (Lesson*) lessonWithID:(int32_t) lessonID;

- (Lesson*) lessonForVocabulary:(Vocabulary*) vocabulary;

- (Lesson*) lessonForVocabularyWithID:(int32_t) vocabularyID;

- (Lesson*) lessonForExerciseCluster:(ExerciseCluster*) exerciseCluster;

- (NSArray*) pearlsForLesson:(Lesson*) lesson;

- (NSArray*) pearlsForLesson:(Lesson*) lesson withType:(ExerciseType) type;

- (Pearl*) pearlForLesson:(Lesson*) lesson withID:(int32_t) pearlID;

- (BOOL) pearlIsDialogPearl:(Pearl*) pearl;

- (Pearl*) pearlForExerciseCluster:(ExerciseCluster*) cluster;

- (Pearl*) firstPearlForLesson:(Lesson*) lesson;

- (NSArray*) dialogPearlsForLesson:(Lesson*) lesson;

- (Vocabulary*) vocabularyWithID:(NSInteger) id;

- (NSArray*) vocabulariesForPearl:(Pearl*) pearl;

- (NSArray*) vocabulariesInSameChunkAsVocabularyWithID:(uint) vocabularyID;

- (NSArray*) allVocabularies;

//- (NSArray*) dialogsForPearl:(Pearl*) pearl;
//
//- (Dialog*) dialogForPearl:(Pearl*) pearl withID:(uint)id;

- (NSArray*) dialogLinesForExercise:(Exercise*) exercise;

- (NSArray*) exerciseClustersForPearl:(Pearl*) pearl;

- (ExerciseCluster*) exerciseClusterForPearl:(Pearl*) pearl withID:(int32_t) clusterID;

- (ExerciseCluster*) firstClusterForPearl:(Pearl*) pearl;

- (ExerciseCluster*) firstClusterForLesson:(Lesson*) lesson;

- (NSArray*) exercisesForPearl:(Pearl*) pearl;

- (NSArray*) exercisesForPearl:(Pearl*) pearl beginningAtExerciseCluster:(ExerciseCluster*) exerciseCluster;

- (NSArray*) exercisesForPearl:(Pearl*) pearl withType:(ExerciseType) type;

- (NSArray*) exercisesForExerciseCluster:(ExerciseCluster*) exerciseCluster;

//- (NSArray*) exercisesForPearl:(Pearl*) pearl withID:(uint) id;

- (NSArray*) exerciseLinesForExercise:(Exercise*) exercise;


#pragma mark - Next Pearl

- (Pearl*) nextPearlForPearl:(Pearl*) pearl;

- (ExerciseCluster*) nextExerciseClusterForExerciseCluster:(ExerciseCluster*) exerciseCluster inSameLesson:(BOOL) inSameLesson;

//- (void) test;


- (void) populateForLanguage;


@end
