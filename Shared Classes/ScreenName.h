//
//  ScreenName.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Course.h"
#import "Lesson.h"
#import "Pearl.h"
#import "ExerciseCluster.h"


@interface ScreenName : NSObject


+ (NSString*) nameForCourse:(Course*) course;

+ (NSString*) nameForLesson:(Lesson*) lesson;

+ (NSString*) nameForPearl:(Pearl*) pearl;

+ (NSString*) nameForCluster:(ExerciseCluster*) cluster;

@end
