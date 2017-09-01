//
//  UserLesson.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserCourse, UserPearl;

NS_ASSUME_NONNULL_BEGIN

@interface UserLesson : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "UserLesson+CoreDataProperties.h"
