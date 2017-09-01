//
//  Pearl+CoreDataProperties.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Pearl.h"

NS_ASSUME_NONNULL_BEGIN

@interface Pearl (CoreDataProperties)

@property (nonatomic) int32_t id;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) Lesson *lesson;

@end

NS_ASSUME_NONNULL_END
