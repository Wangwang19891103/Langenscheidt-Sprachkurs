//
//  ExerciseDictionary.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Exercise.h"
#import "ExerciseCluster.h"
#import "ExerciseLine.h"
#import "ContentDataManager.h"


@interface ExerciseDictionary : NSObject

+ (NSDictionary*) dictionaryForExercise:(Exercise*) exercise;

+ (NSDictionary*) dictionaryForVocabularies:(NSArray*) vocabularies;

@end
