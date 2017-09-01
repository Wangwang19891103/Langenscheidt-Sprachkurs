//
//  ExerciseTypes.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseTypes.h"


@implementation ExerciseTypes


+ (NSString*) stringForExerciseType:(ExerciseType) type {
    
    switch (type) {
            
        case NONE:
            return @"<KEIN ÜBUNGSTYP>";
            break;
            
        case UNKNOWN:
            return @"<Unbekannter Übungstyp>";
            break;
            
        case LTXT_STANDARD:
            return @"Lückentext mit Standard-Keyboard";
            
        case LTXT_STANDARD_TABULAR:
            return @"Lückentext mit Standard-Keyboard (tabellarisch)";
            
        case LTXT_CUSTOM:
            return @"Lückentext mit Custom-Keyboard";
            
        case LTXT_CUSTOM_TABULAR:
            return @"Lückentext mit Custom-Keyboard (tabellarisch)";
            
        case DND:
            return @"Drag and Drop";

        case DND_TABULAR:
            return @"Drag and Drop (tabellarisch)";

        case VOCABFLOW:
            return @"Vocab Flow";
            
        case MATCHER:
            return @"Matcher (vertikal)";
            
        case SNAKE:
            return @"Schlange";
            
        case SCR:
            return @"Scrambled Sentences";
            
        case MATPIC:
            return @"MATPIC";
            
        case MCH:
            return @"Multiple Choice";
            
        case DIALOG:
            return @"Dialog";
            
        case RANDOM_VOC_SINGLE:
            return @"Random Vocabulary Single";
            
        case RANDOM_VOC_MULTIPLE:
            return @"Random Vocabulary Multiple";
            
            
        default:
            break;
    }
}


+ (NSString*) shortStringForExerciseType:(ExerciseType) type {
    
    switch (type) {
            
        case NONE:
            return @"<KEIN TYP>";
            break;
            
        case UNKNOWN:
            return @"<Unbekannt>";
            break;
            
        case LTXT_STANDARD:
            return @"LTXT Standard";
            
        case LTXT_STANDARD_TABULAR:
            return @"LTXT Standard-tab";
            
        case LTXT_CUSTOM:
            return @"LTXT Custom";
            
        case LTXT_CUSTOM_TABULAR:
            return @"LTXT Custom-tab";
            
        case DND:
            return @"DND";
            
        case DND_TABULAR:
            return @"DND tab";
            
        case VOCABFLOW:
            return @"Vocab Flow";
            
        case MATCHER:
            return @"Matcher";
            
        case SNAKE:
            return @"Schlange";
            
        case SCR:
            return @"Scrambled Sentences";
            
        case MATPIC:
            return @"MATPIC";
            
        case MCH:
            return @"Multiple Choice";
            
        case DIALOG:
            return @"Dialog";
            
        case RANDOM_VOC_SINGLE:
            return @"Random Voc Single";
            
        case RANDOM_VOC_MULTIPLE:
            return @"Random Voc Multiple";
            
            
        default:
            break;
    }
}



+ (ExerciseInputType) inputTypeForExerciseType:(ExerciseType)type {
    
    switch (type) {
        case LTXT_STANDARD:
        case LTXT_STANDARD_TABULAR:
            return ExerciseInputTypeStandard;
            break;
            
        case LTXT_CUSTOM:
        case LTXT_CUSTOM_TABULAR:
        case RANDOM_VOC_SINGLE:
            return ExerciseInputTypeScrambledLetters;
            break;
            
        case DND:
        case DND_TABULAR:
            return ExerciseInputTypeDragAndDrop;
            break;
            
        default:
            return ExerciseInputTypeStandard;
            break;
    }
}


+ (BOOL) isTypeImplemented:(ExerciseType) type {
    
    switch (type) {
            
        case UNKNOWN:
            
        case LTXT_STANDARD:
        case LTXT_STANDARD_TABULAR:
        case LTXT_CUSTOM:
        case LTXT_CUSTOM_TABULAR:
        case DND:
        case DND_TABULAR:
        case SCR:
        case SNAKE:
        case MATCHER:
        case MATPIC:
        case MCH:
        case VOCABFLOW:
        case DIALOG:
        case RANDOM_VOC_SINGLE:
        case RANDOM_VOC_MULTIPLE:
            return YES;
            break;
            
        default:
            return NO;
            break;
    }
}


+ (NSArray*) implementedTypes {
    
    NSMutableArray* types = [NSMutableArray array];

    for (ExerciseType type = UNKNOWN; type <= RANDOM_VOC_SINGLE; ++type) {
        
        if ([self isTypeImplemented:type]) {
            
            [types addObject:@(type)];
        }
    }
    
    return types;
}


#pragma mark - Exercise types for text (gap text exercises)

+ (NSArray*) possibleExerciseTypesForText:(NSString*) text {
    
    NSMutableArray* possibleTypes = [NSMutableArray array];
    
    
    
    return possibleTypes;
}


+ (ExerciseType) randomExerciseTypeForText:(NSString*) text {
    
    NSArray* possibleTypes = [ExerciseTypes possibleExerciseTypesForText:text];
    
    uint index = arc4random() % possibleTypes.count;
    
    return [possibleTypes[index] integerValue];
}


@end