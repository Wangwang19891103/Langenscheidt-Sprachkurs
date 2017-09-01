//
//  UserLesson+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserLesson.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserLesson (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nonatomic) BOOL isCurrentLesson;
@property (nonatomic) int16_t run;
@property (nonatomic) int16_t score;
@property (nullable, nonatomic, retain) NSSet<UserPearl *> *pearls;
@property (nullable, nonatomic, retain) UserCourse *course;

@end

@interface UserLesson (CoreDataGeneratedAccessors)

- (void)addPearlsObject:(UserPearl *)value;
- (void)removePearlsObject:(UserPearl *)value;
- (void)addPearls:(NSSet<UserPearl *> *)values;
- (void)removePearls:(NSSet<UserPearl *> *)values;

@end

NS_ASSUME_NONNULL_END
