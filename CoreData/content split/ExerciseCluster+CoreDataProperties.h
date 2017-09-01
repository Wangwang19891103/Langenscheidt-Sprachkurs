//
//  ExerciseCluster+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ExerciseCluster.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExerciseCluster (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nonatomic) int32_t pearlID;
@property (nullable, nonatomic, retain) NSSet<Exercise *> *exercises;

@end

@interface ExerciseCluster (CoreDataGeneratedAccessors)

- (void)addExercisesObject:(Exercise *)value;
- (void)removeExercisesObject:(Exercise *)value;
- (void)addExercises:(NSSet<Exercise *> *)values;
- (void)removeExercises:(NSSet<Exercise *> *)values;

@end

NS_ASSUME_NONNULL_END
