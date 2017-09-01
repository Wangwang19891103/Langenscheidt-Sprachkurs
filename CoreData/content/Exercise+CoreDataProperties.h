//
//  Exercise+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Exercise.h"

NS_ASSUME_NONNULL_BEGIN

@interface Exercise (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *audioFile;
@property (nullable, nonatomic, retain) NSString *audioRange;
@property (nullable, nonatomic, retain) NSString *explanation;
@property (nonatomic) int32_t id;
@property (nullable, nonatomic, retain) NSString *instruction;
@property (nullable, nonatomic, retain) NSString *popupFile;
@property (nullable, nonatomic, retain) NSString *topText;
@property (nonatomic) int16_t type;
@property (nullable, nonatomic, retain) ExerciseCluster *cluster;
@property (nullable, nonatomic, retain) NSSet<DialogLine *> *lines;
@property (nullable, nonatomic, retain) NSSet<DialogLine *> *dialogLines;

@end

@interface Exercise (CoreDataGeneratedAccessors)

- (void)addLinesObject:(DialogLine *)value;
- (void)removeLinesObject:(DialogLine *)value;
- (void)addLines:(NSSet<DialogLine *> *)values;
- (void)removeLines:(NSSet<DialogLine *> *)values;

- (void)addDialogLinesObject:(DialogLine *)value;
- (void)removeDialogLinesObject:(DialogLine *)value;
- (void)addDialogLines:(NSSet<DialogLine *> *)values;
- (void)removeDialogLines:(NSSet<DialogLine *> *)values;

@end

NS_ASSUME_NONNULL_END
