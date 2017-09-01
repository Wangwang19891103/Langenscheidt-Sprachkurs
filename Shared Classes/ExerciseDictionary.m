//
//  ExerciseDictionary.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExerciseDictionary.h"

@implementation ExerciseDictionary

+ (NSDictionary*) dictionaryForExercise:(Exercise*) exercise {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    dict[@"exerciseObject"] = exercise;
//    dict[@"clusterID"] = @(exercise.cluster.id);
    dict[@"exerciseID"] = @(exercise.id);
    dict[@"type"] = @(exercise.type);
    dict[@"instruction"] = exercise.instruction;
    dict[@"topText"] = exercise.topText;
    dict[@"explanation"] = exercise.explanation;
    dict[@"popupFile"] = exercise.popupFile;
    dict[@"audioFile"] = exercise.audioFile;
    dict[@"audioRange"] = exercise.audioRange;
    dict[@"lines"] = [NSMutableArray array];
    
    NSArray* exerciseLines = [[ContentDataManager instance] exerciseLinesForExercise:exercise];
    
    for (ExerciseLine* line in exerciseLines) {
        
        NSMutableDictionary* lineDict = [NSMutableDictionary dictionary];
        
        lineDict[@"field1"] = line.field1;
        lineDict[@"field2"] = line.field2;
        lineDict[@"field3"] = line.field3;
        lineDict[@"field4"] = line.field4;
        lineDict[@"field5"] = line.field5;
        
        [dict[@"lines"] addObject:lineDict];
    }

    
    // dialog lines
    
    dict[@"dialogLines"] = [NSMutableArray array];
    
    NSArray* dialogLines = [[ContentDataManager instance] dialogLinesForExercise:exercise];
    
    for (DialogLine* line in dialogLines) {
        
        NSMutableDictionary* lineDict = [NSMutableDictionary dictionary];

        lineDict[@"audioFile"] = line.audioFile;
        lineDict[@"audioRange"] = line.audioRange;
        lineDict[@"popupFile"] = line.popupFile;
        lineDict[@"speaker"] = line.speaker;
        lineDict[@"textLang1"] = line.textLang1;
        lineDict[@"textLang2"] = line.textLang2;
        lineDict[@"vocabularyIDs"] = line.vocabularyIDs;
        
        [dict[@"dialogLines"] addObject:lineDict];
    }

    return dict;
}


+ (NSDictionary*) dictionaryForVocabularies:(NSArray*) vocabularies {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"vocabularies"] = [NSMutableArray array];
    
    for (Vocabulary* vocabulary in vocabularies) {
        
        NSMutableDictionary* vocDict = [NSMutableDictionary dictionary];
        
        vocDict[@"vocabularyID"] = @(vocabulary.id);
        vocDict[@"prefixLang1"] = vocabulary.prefixLang1;
        vocDict[@"textLang1"] = vocabulary.textLang1;
        vocDict[@"prefixLang2"] = vocabulary.prefixLang2;
        vocDict[@"textLang2"] = vocabulary.textLang2;
        vocDict[@"imageFile"] = vocabulary.imageFile;
        vocDict[@"audioFile"] = vocabulary.audioFile;
        
        [dict[@"vocabularies"] addObject:vocDict];
    }
    
    return dict;
}

@end
