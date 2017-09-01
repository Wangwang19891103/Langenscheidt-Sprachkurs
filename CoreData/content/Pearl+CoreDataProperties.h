//
//  Pearl+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Pearl.h"

NS_ASSUME_NONNULL_BEGIN

@interface Pearl (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSSet<ExerciseCluster *> *exerciseClusters;
@property (nullable, nonatomic, retain) Lesson *lesson;
@property (nullable, nonatomic, retain) NSSet<Vocabulary *> *vocabularies;

@end

@interface Pearl (CoreDataGeneratedAccessors)

- (void)addExerciseClustersObject:(ExerciseCluster *)value;
- (void)removeExerciseClustersObject:(ExerciseCluster *)value;
- (void)addExerciseClusters:(NSSet<ExerciseCluster *> *)values;
- (void)removeExerciseClusters:(NSSet<ExerciseCluster *> *)values;

- (void)addVocabulariesObject:(Vocabulary *)value;
- (void)removeVocabulariesObject:(Vocabulary *)value;
- (void)addVocabularies:(NSSet<Vocabulary *> *)values;
- (void)removeVocabularies:(NSSet<Vocabulary *> *)values;

@end

NS_ASSUME_NONNULL_END
