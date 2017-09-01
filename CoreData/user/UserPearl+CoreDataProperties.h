//
//  UserPearl+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserPearl.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserPearl (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nonatomic) int16_t score;
@property (nullable, nonatomic, retain) NSSet<UserExerciseCluster *> *clusters;
@property (nullable, nonatomic, retain) UserLesson *lesson;

@end

@interface UserPearl (CoreDataGeneratedAccessors)

- (void)addClustersObject:(UserExerciseCluster *)value;
- (void)removeClustersObject:(UserExerciseCluster *)value;
- (void)addClusters:(NSSet<UserExerciseCluster *> *)values;
- (void)removeClusters:(NSSet<UserExerciseCluster *> *)values;

@end

NS_ASSUME_NONNULL_END
