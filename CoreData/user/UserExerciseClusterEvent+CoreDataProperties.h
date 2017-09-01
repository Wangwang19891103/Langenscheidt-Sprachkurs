//
//  UserExerciseClusterEvent+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserExerciseClusterEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserExerciseClusterEvent (CoreDataProperties)

@property (nonatomic) NSTimeInterval date;
@property (nonatomic) int16_t maxScore;
@property (nonatomic) int16_t run;
@property (nonatomic) int16_t score;
@property (nullable, nonatomic, retain) UserExerciseCluster *cluster;

@end

NS_ASSUME_NONNULL_END
