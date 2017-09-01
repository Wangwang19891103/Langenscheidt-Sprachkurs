//
//  ContentDataManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 29.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ContentDataManager.h"
#import "ContentManager.h"


#define PEARL_ID_RANGE_VOCABULARY       10000000  // 10 million
#define PEARL_ID_RANGE_DIALOG           20000000
#define PEARL_ID_RANGE_GRAMMAR          30000000
#define PEARL_ID_RANGE_REPETITION       40000000


@implementation ContentDataManager

@synthesize dataManager;


- (id) init {
    
    self = [super init];
    
    dataManager = [DataManager2 createInstanceWithName:@"content" modelName:@"contentSplit"];

    [self _loadStructureStore];
    
    [self _loadTeaserStore];
    
    [self reloadCourseStores];
    
    return self;
}


+ (instancetype) instance {
    
    static ContentDataManager* __instance = nil;
    
    @synchronized(self) {
        
        if (!__instance) {
            
            __instance = [[ContentDataManager alloc] init];
        }
    }
    
    return __instance;
}



#pragma mark - Include Stores

- (void) _loadStructureStore {
    
    [dataManager addStoreWithName:@"structure" configuration:@"structure" location:DataManagerStoreLocationBundle];
}


- (void) _loadTeaserStore {

    NSString* teaserDBPath = [[[[[NSBundle mainBundle] pathForResource:@"ContentData" ofType:nil] stringByAppendingPathComponent:@"teaser"] stringByAppendingPathComponent:@"database"] stringByAppendingPathComponent:@"content.sqlite"];
    
    [dataManager addStoreAtPath:teaserDBPath withName:@"teaser" configuration:@"exercises"];
}


- (void) reloadCourseStores {

    // remove course stores
    
    NSDictionary* stores = [NSDictionary dictionaryWithDictionary:self.dataManager.stores];
    
    for (NSString* storeName in stores.allKeys) {
        
        if (![storeName isEqualToString:@"structure"]
            && ![storeName isEqualToString:@"teaser"]) {
            
            [self.dataManager removeStoreWithName:storeName];
        }
    }
    
    
    // add available course stores (ask ContentManager)
    
    NSArray* courseStorePaths = [[ContentManager instance] availableCourseStorePaths];
    
    for (NSString* courseStorePath in courseStorePaths) {
        
        [dataManager addStoreAtPath:courseStorePath withConfiguration:@"exercises"];
    }
}




#pragma mark - Courses

- (NSArray*) courses {
    
    return [self.dataManager fetchDataForEntityName:@"Course" withPredicate:nil sortedBy:@"id", nil];
}


- (Course*) courseForVocabulary:(Vocabulary*) vocabulary {
    
    Pearl* pearl = [[self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", vocabulary.pearlID] sortedBy:nil] firstObject];
    
    return pearl.lesson.course;
}


- (Course*) courseForExerciseCluster:(ExerciseCluster*) exerciseCluster {
    
    Pearl* pearl = [[self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", exerciseCluster.pearlID] sortedBy:nil] firstObject];
    
    return pearl.lesson.course;
}




#pragma mark - Lessons

- (NSArray*) lessonsForCourse:(Course*) course {
    
    return [self.dataManager fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"course == %@", course] sortedBy:@"id", nil];
}


- (NSArray*) allLessons {
    
    return [self.dataManager fetchDataForEntityName:@"Lesson" withPredicate:nil sortedBy:@"id", nil];
}


//- (NSArray*) lessonsForCourse:(Course *)course withType:(ExerciseType) type {
//    
//    return [self.dataManager fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"course == %@ AND SUBQUERY(pearls, $pearl, SUBQUERY($pearl.exerciseClusters, $cluster, SUBQUERY($cluster.exercises, $exercise, $exercise.type == %d).@count > 0).@count > 0).@count > 0", course, type] sortedBy:@"id", nil];
//}


- (Lesson*) lessonWithID:(int32_t) lessonID {

    NSArray* results = [self.dataManager fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", lessonID] sortedBy:nil];
    
    return results.firstObject;
}


- (Lesson*) firstLessonForCourse:(Course*) course {
    
    NSArray* lessons = [self lessonsForCourse:course];
    
    return lessons.firstObject;
}


- (Lesson*) lessonForVocabulary:(Vocabulary*) vocabulary {
    
    Pearl* pearl = [[self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", vocabulary.pearlID] sortedBy:nil] firstObject];
    
    return pearl.lesson;
}


- (Lesson*) lessonForVocabularyWithID:(int32_t) vocabularyID {
    
    NSArray* results = [self.dataManager fetchDataForEntityName:@"Vocabulary" withPredicate:[NSPredicate predicateWithFormat:@"id = %d", vocabularyID] sortedBy:nil];
    
    Vocabulary* vocabulary = results.firstObject;
    
    return [self lessonForVocabulary:vocabulary];
}


- (Lesson*) lessonForExerciseCluster:(ExerciseCluster*) exerciseCluster {
    
    Pearl* pearl = [[self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", exerciseCluster.pearlID] sortedBy:nil] firstObject];
    
    return pearl.lesson;
}



#pragma mark - Pearls

- (NSArray*) pearlsForLesson:(Lesson*) lesson {
    
    return [self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"lesson == %@", lesson] sortedBy:@"id", nil];
}


//- (NSArray*) pearlsForLesson:(Lesson*) lesson withType:(ExerciseType) type {
//    
//    return [self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"lesson == %@ AND SUBQUERY(exerciseClusters, $cluster, SUBQUERY($cluster.exercises, $exercise, $exercise.type == %d).@count > 0).@count > 0", lesson, type] sortedBy:@"id", nil];
//}


- (Pearl*) pearlForLesson:(Lesson*) lesson withID:(int32_t) pearlID {
    
    NSArray* results = [self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"lesson == %@ AND id == %d", lesson, pearlID] sortedBy:nil];
    
    return results.firstObject;
}


- (BOOL) pearlIsDialogPearl:(Pearl*) pearl {
    
    BOOL pearlIsDialogPearl = NO;
    
    NSArray* dialogPearls = [self dialogPearlsForLesson:pearl.lesson];
    
    pearlIsDialogPearl = [dialogPearls containsObject:pearl];
    
    return pearlIsDialogPearl;
}


- (Pearl*) pearlForExerciseCluster:(ExerciseCluster*) cluster {  // cross store
    
    return [[self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", cluster.pearlID] sortedBy:nil] firstObject];
}


- (Pearl*) firstPearlForLesson:(Lesson*) lesson {
    
    NSArray* pearls = [self pearlsForLesson:lesson];
    
    return pearls.firstObject;
}


//- (NSArray*) dialogPearlsForLesson:(Lesson*) lesson {
//    
//    ExerciseType dialogType = DIALOG;
//
//    return [self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:
//            [NSPredicate predicateWithFormat:
//             @"lesson.id == %d AND "
//                "SUBQUERY("
//                    "exerciseClusters, "
//                    "$exerciseCluster, "
//                    "SUBQUERY("
//                        "$exerciseCluster.exercises, "
//                        "$exercise, "
//                        "$exercise.type == %d"
//                    ").@count == SUBQUERY("
//                        "$exerciseCluster.exercises, "
//                        "$exercise, "
//                        "$exercise != nil"
//                    ").@count"
//                ").@count == exerciseClusters.@count",
//             lesson.id,
//             dialogType]
//                                           sortedBy:nil];
//}


- (NSArray*) dialogPearlsForLesson:(Lesson*) lesson {  // cross store

    return [self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"lesson == %@ AND id >= 20000000 AND id < 30000000", lesson] sortedBy:@"id", nil];
}



#pragma mark - Vocabularies


- (Vocabulary*) vocabularyWithID:(NSInteger) id {
    
    return [[self.dataManager fetchDataForEntityName:@"Vocabulary" withPredicate:[NSPredicate predicateWithFormat:@"id == %ld", id] sortedBy:nil] firstObject];
}


- (NSArray*) vocabulariesForPearl:(Pearl*) pearl {  // cross store
    
    return [self.dataManager fetchDataForEntityName:@"Vocabulary" withPredicate:[NSPredicate predicateWithFormat:@"pearlID == %d", pearl.id] sortedBy:@"id", nil];
}


- (NSArray*) vocabulariesInSameChunkAsVocabularyWithID:(uint)vocabularyID {  // cross store
    
    Vocabulary* vocabulary = [[self.dataManager fetchDataForEntityName:@"Vocabulary" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", vocabularyID] sortedBy:nil] firstObject];
    
    NSArray* vocabularies = [self.dataManager fetchDataForEntityName:@"Vocabulary" withPredicate:[NSPredicate predicateWithFormat:@"pearlID == %d", vocabulary.pearlID] sortedBy:@"id", nil];
    
    return vocabularies;
}


- (NSArray*) allVocabularies {
    
    NSArray* vocabularies = [self.dataManager fetchDataForEntityName:@"Vocabulary" withPredicate:nil sortedBy:nil];
    
//    NSSortDescriptor* descriptor = [[NSSortDescriptor alloc] initWithKey:@"textLang2" ascending:YES selector:@selector(caseInsensitiveCompare:)];
//    
//    NSArray* sortedVocabularies = [vocabularies sortedArrayUsingDescriptors:@[descriptor]];
    
    return vocabularies;
}



#pragma mark - Dialogs

- (NSArray*) dialogLinesForExercise:(Exercise*) exercise {
    
    return [self.dataManager fetchDataForEntityName:@"DialogLine" withPredicate:[NSPredicate predicateWithFormat:@"exercise == %@", exercise] sortedBy:@"id", nil];
}


//- (NSArray*) dialogsForPearl:(Pearl*) pearl {
//    
//    return [self.dataManager fetchDataForEntityName:@"Dialog" withPredicate:[NSPredicate predicateWithFormat:@"pearl == %@", pearl] sortedBy:@"id", nil];
//}
//
//
//- (Dialog*) dialogForPearl:(Pearl*) pearl withID:(uint)id {
//    
//    return [[self.dataManager fetchDataForEntityName:@"Dialog" withPredicate:[NSPredicate predicateWithFormat:@"pearl == %@ AND id == %d", pearl, id] sortedBy:nil] firstObject];
//}


#pragma mark - ExerciseClusters

- (NSArray*) exerciseClustersForPearl:(Pearl*) pearl {  // cross store
    
    return [self.dataManager fetchDataForEntityName:@"ExerciseCluster" withPredicate:[NSPredicate predicateWithFormat:@"pearlID == %d", pearl.id] sortedBy:@"id", nil];
}


- (ExerciseCluster*) exerciseClusterForPearl:(Pearl*) pearl withID:(int32_t) clusterID {  // cross store
    
    NSArray* results = [self.dataManager fetchDataForEntityName:@"ExerciseCluster" withPredicate:[NSPredicate predicateWithFormat:@"pearlID == %d AND id == %d", pearl.id, clusterID] sortedBy:nil];
    
    return results.firstObject;
}


- (ExerciseCluster*) firstClusterForPearl:(Pearl*) pearl {  // cross store
    
    NSArray* clusters = [self exerciseClustersForPearl:pearl];
    
    return clusters.firstObject;
}


- (ExerciseCluster*) firstClusterForLesson:(Lesson*) lesson {  // cross store
    
    Pearl* firstPearl = [self firstPearlForLesson:lesson];
    
    NSArray* clusters = [self exerciseClustersForPearl:firstPearl];
    
    return clusters.firstObject;
}




#pragma mark - Exercises

- (NSArray*) exercisesForPearl:(Pearl*) pearl {  // cross store
    
    return [self.dataManager fetchDataForEntityName:@"Exercise" withPredicate:[NSPredicate predicateWithFormat:@"cluster.pearlID == %d", pearl.id] sortedBy:@"cluster.id", @"id", nil];
}


- (NSArray*) exercisesForPearl:(Pearl*) pearl beginningAtExerciseCluster:(ExerciseCluster*) exerciseCluster {  // cross store
    
//    return [self.dataManager fetchDataForEntityName:@"ExerciseCluster" withPredicate:[NSPredicate predicateWithFormat:@"pearl == %@ AND id >= %d", pearl, exerciseCluster.id] sortedBy:@"id", nil];
    
    return [self.dataManager fetchDataForEntityName:@"Exercise" withPredicate:[NSPredicate predicateWithFormat:@"cluster.pearlID == %d AND cluster.id >= %d", pearl.id, exerciseCluster.id] sortedBy:@"cluster.id", @"id", nil];
}


- (NSArray*) exercisesForPearl:(Pearl*) pearl withType:(ExerciseType) type {  // cross store
    
    return [self.dataManager fetchDataForEntityName:@"Exercise" withPredicate:[NSPredicate predicateWithFormat:@"cluster.pearlID == %d AND type == %d", pearl.id, type] sortedBy:@"cluster.id", @"id", nil];
}


- (NSArray*) exercisesForExerciseCluster:(ExerciseCluster*) exerciseCluster {
    
    return [self.dataManager fetchDataForEntityName:@"Exercise" withPredicate:[NSPredicate predicateWithFormat:@"cluster == %@", exerciseCluster] sortedBy:@"id", nil];
}


//- (NSArray*) exercisesForPearl:(Pearl*) pearl withID:(uint) id {
//    
//    return [self.dataManager fetchDataForEntityName:@"Exercise" withPredicate:[NSPredicate predicateWithFormat:@"pearl == %@ AND id == %d", pearl, id] sortedBy:@"id", nil];
//}



#pragma mark - ExerciseLines 

- (NSArray*) exerciseLinesForExercise:(Exercise*) exercise {
    
    return [self.dataManager fetchDataForEntityName:@"ExerciseLine" withPredicate:[NSPredicate predicateWithFormat:@"exercise == %@", exercise] sortedBy:@"id", nil];
}


#pragma mark - Next Pearl

- (ExerciseCluster*) nextExerciseClusterForExerciseCluster:(ExerciseCluster*) exerciseCluster inSameLesson:(BOOL) inSameLesson {  // cross store

    ExerciseCluster* nextExerciseCluster = nil;

    
    // get sibling clusters
    
    NSArray* siblingClusters = [self.dataManager fetchDataForEntityName:@"ExerciseCluster" withPredicate:[NSPredicate predicateWithFormat:@"pearlID == %d", exerciseCluster.pearlID] sortedBy:@"id", nil];
    
    
    // case 1: pearl has more clusters -> next cluster in same pearl
    // case 2: cluster is last cluster in pearl -> first cluster in next pearl (BUT not circling to another lesson, but instead back to the top of current lesson

    
    for (int i = 0; i < siblingClusters.count; ++i) {
        
        ExerciseCluster* siblingCluster = siblingClusters[i];
        
        if (siblingCluster.id == exerciseCluster.id) {  // cluster found in siblings
            
            if (i < siblingClusters.count - 1) {  // cluster is not last in pearl
                
                // next pearl is the following pearl in same lesson
                
                nextExerciseCluster = siblingClusters[i+1];
            }
            else {  // cluster is last in pearl
                
                // next cluster is the first cluster in first pearl in SAME lesson
                
                Pearl* clusterPearl = [[self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", exerciseCluster.pearlID] sortedBy:nil] firstObject];
                
                Pearl* nextPearl = [self nextPearlForPearl:clusterPearl inSameLesson:inSameLesson];  // NO will skip over to next lesson
                nextExerciseCluster = [self firstClusterForPearl:nextPearl];
            }
            
            break;
        }
    }
    
    
    NSAssert(nextExerciseCluster, @"");
    
    
    return nextExerciseCluster;
}


- (Pearl*) nextPearlForPearl:(Pearl*) pearl {

    return [self nextPearlForPearl:pearl inSameLesson:NO];
}


- (Pearl*) nextPearlForPearl:(Pearl*) pearl inSameLesson:(BOOL) inSameLesson {

    Pearl* nextPearl = nil;
    
    
    // get sibling pearls
    
    NSArray* siblingPearls = [self.dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"lesson == %@", pearl.lesson] sortedBy:@"id", nil];
    
    
    // case 1: lesson has more pearls -> next pearl in same lesson
    // case 2: pearl is last pearl in lesson -> first pearl in next lesson

    
    for (int i = 0; i < siblingPearls.count; ++i) {
        
        Pearl* siblingPearl = siblingPearls[i];
        
        if (siblingPearl.id == pearl.id) {  // pearl found in siblings
            
            if (i < siblingPearls.count - 1) {  // pearl is not last in lesson
                
                // next pearl is the following pearl in same lesson
                
                nextPearl = siblingPearls[i+1];
            }
            else {  // pearl is last in lesson
                
                if (inSameLesson) {

                    // next pearl is the first pearl in SAME lesson
                    
                    nextPearl = [self firstPearlForLesson:pearl.lesson];
                }
                else {
                
                    // next pearl is the first pearl in following lesson (circling back to the start of lessons/courses
                    
                    Lesson* nextLesson = [self nextLessonForLesson:pearl.lesson];
                    nextPearl = [self firstPearlForLesson:nextLesson];
                }
            }
            
            break;
        }
    }
    
    
    NSAssert(nextPearl, @"");
    
    
    return nextPearl;
}


- (Lesson*) nextLessonForLesson:(Lesson*) lesson {
    
    // case 1: lesson is not last in its course
    // case 2: lesson is last in its course
    
    Lesson* nextLesson = nil;
    
    NSArray* siblingLessons = [self.dataManager fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"course == %@", lesson.course] sortedBy:@"id", nil];
    
    
    for (int i = 0; i < siblingLessons.count; ++i) {
        
        Lesson* siblingLesson = siblingLessons[i];
        
        if (siblingLesson.id == lesson.id) {  // found lesson in siblings
            
            if (i < siblingLessons.count - 1) {  // lesson is not last in course
                
                // next lesson is the following lesson in same course
                
                nextLesson = siblingLessons[i + 1];
            }
            else {  // lesson is last in course
                
                // next lesson is the first lesson in following course (circling back to start of lessons/courses
                
                Course* nextCourse = [self nextCourseForCourse:lesson.course];
                nextLesson = [self firstLessonForCourse:nextCourse];
            }

            break;
        }
    }
    
    return nextLesson;
}


- (Course*) nextCourseForCourse:(Course*) course {
    
    // case 1: course is not last in language
    // case 2: course is last in language
    
    Course* nextCourse = nil;
    
    NSArray* siblingCourses = [self courses];
    
    
    for (int i = 0; i < siblingCourses.count; ++i) {
        
        Course* siblingCourse = siblingCourses[i];
        
        if (siblingCourse.id == course.id) {  // found course in siblings
            
            if (i < siblingCourses.count -1) {  // course is not last in language
                
                // next course is the following course in same language
                
                nextCourse = siblingCourses[i + 1];
            }
            else {  // course is last in language
                
                // next course is the first course in the SAME language (!!) (circling back to start of language)
                
                nextCourse = siblingCourses[0];
            }

            break;
        }
    }
    
    return nextCourse;
}







//- (void) test {
//    
//    NSArray* voc = [self.dataManager fetchDataForEntityName:@"Vocabulary" withPredicate:nil sortedBy:@"id", nil];
//}
@end
