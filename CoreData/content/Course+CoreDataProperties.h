//
//  Course+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Course.h"

NS_ASSUME_NONNULL_BEGIN

@interface Course (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nullable, nonatomic, retain) NSString *imageFile;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSSet<Lesson *> *lessons;

@end

@interface Course (CoreDataGeneratedAccessors)

- (void)addLessonsObject:(Lesson *)value;
- (void)removeLessonsObject:(Lesson *)value;
- (void)addLessons:(NSSet<Lesson *> *)values;
- (void)removeLessons:(NSSet<Lesson *> *)values;

@end

NS_ASSUME_NONNULL_END
