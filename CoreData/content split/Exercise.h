//
//  Exercise.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DialogLine, ExerciseCluster, ExerciseLine;

NS_ASSUME_NONNULL_BEGIN

@interface Exercise : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Exercise+CoreDataProperties.h"
