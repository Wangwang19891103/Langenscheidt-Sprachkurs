//
//  Lesson+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Lesson.h"

NS_ASSUME_NONNULL_BEGIN

@interface Lesson (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nullable, nonatomic, retain) NSString *imageFile;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) Course *course;
@property (nullable, nonatomic, retain) NSSet<Pearl *> *pearls;

@end

@interface Lesson (CoreDataGeneratedAccessors)

- (void)addPearlsObject:(Pearl *)value;
- (void)removePearlsObject:(Pearl *)value;
- (void)addPearls:(NSSet<Pearl *> *)values;
- (void)removePearls:(NSSet<Pearl *> *)values;

@end

NS_ASSUME_NONNULL_END
