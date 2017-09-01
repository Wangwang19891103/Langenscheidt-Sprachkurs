//
//  UserExerciseCluster+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserExerciseCluster.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserExerciseCluster (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nonatomic) int16_t run;
@property (nonatomic) int16_t score;
@property (nullable, nonatomic, retain) NSSet<UserExerciseClusterEvent *> *events;
@property (nullable, nonatomic, retain) UserPearl *pearl;

@end

@interface UserExerciseCluster (CoreDataGeneratedAccessors)

- (void)addEventsObject:(UserExerciseClusterEvent *)value;
- (void)removeEventsObject:(UserExerciseClusterEvent *)value;
- (void)addEvents:(NSSet<UserExerciseClusterEvent *> *)values;
- (void)removeEvents:(NSSet<UserExerciseClusterEvent *> *)values;

@end

NS_ASSUME_NONNULL_END
