//
//  ExerciseCluster+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ExerciseCluster.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExerciseCluster (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nullable, nonatomic, retain) NSSet<Exercise *> *exercises;
@property (nullable, nonatomic, retain) Pearl *pearl;

@end

@interface ExerciseCluster (CoreDataGeneratedAccessors)

- (void)addExercisesObject:(Exercise *)value;
- (void)removeExercisesObject:(Exercise *)value;
- (void)addExercises:(NSSet<Exercise *> *)values;
- (void)removeExercises:(NSSet<Exercise *> *)values;

@end

NS_ASSUME_NONNULL_END
