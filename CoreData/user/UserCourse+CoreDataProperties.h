//
//  UserCourse+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "UserCourse.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserCourse (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nonatomic) int16_t score;
@property (nullable, nonatomic, retain) NSSet<UserLesson *> *lessons;

@end

@interface UserCourse (CoreDataGeneratedAccessors)

- (void)addLessonsObject:(UserLesson *)value;
- (void)removeLessonsObject:(UserLesson *)value;
- (void)addLessons:(NSSet<UserLesson *> *)values;
- (void)removeLessons:(NSSet<UserLesson *> *)values;

@end

NS_ASSUME_NONNULL_END
