//
//  ExerciseLine+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ExerciseLine.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExerciseLine (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *field1;
@property (nullable, nonatomic, retain) NSString *field2;
@property (nullable, nonatomic, retain) NSString *field3;
@property (nullable, nonatomic, retain) NSString *field4;
@property (nullable, nonatomic, retain) NSString *field5;
@property (nonatomic) int32_t id;
@property (nullable, nonatomic, retain) Exercise *exercise;

@end

NS_ASSUME_NONNULL_END
