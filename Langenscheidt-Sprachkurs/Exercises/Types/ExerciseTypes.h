//
//  ExerciseTypes.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 04.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#ifndef ExerciseTypes_h
#define ExerciseTypes_h

typedef NS_ENUM(NSInteger, ExerciseType) {

    NONE,
    UNKNOWN,
    LTXT_STANDARD,
    LTXT_STANDARD_TABULAR,
    LTXT_CUSTOM,
    LTXT_CUSTOM_TABULAR,
    DND,
    DND_TABULAR,
    VOCABFLOW,
    MATCHER,
    SNAKE,
    SCR,
    MATPIC,
    MCH,
    DIALOG,
    
    RANDOM_VOC_MULTIPLE,
    RANDOM_VOC_SINGLE
    
};


typedef NS_ENUM(NSInteger, ExerciseInputType) {
    
    ExerciseInputTypeStandard,
    ExerciseInputTypeScrambledLetters,
    ExerciseInputTypeDragAndDrop
};




@interface ExerciseTypes : NSObject

+ (NSString*) stringForExerciseType:(ExerciseType) type;

+ (NSString*) shortStringForExerciseType:(ExerciseType) type;

+ (ExerciseInputType) inputTypeForExerciseType:(ExerciseType) type;

+ (BOOL) isTypeImplemented:(ExerciseType) type;

+ (NSArray*) implementedTypes;

@end

#endif /* ExerciseTypes_h */
