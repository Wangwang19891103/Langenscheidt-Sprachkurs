//
//  VocabularyFormatter.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 16.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "VocabularyFormatter.h"
#import "ExerciseDictionary.h"


@implementation VocabularyFormatter


+ (NSString*) formattedStringForLanguage:(VocabularyFormatterLanguage) language withVocabulary:(Vocabulary*) vocabulary {
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    dict[@"textLang1"] = vocabulary.textLang1;
    dict[@"prefixLang1"] = vocabulary.prefixLang1;
    dict[@"textLang2"] = vocabulary.textLang2;
    dict[@"prefixLang2"] = vocabulary.prefixLang2;
    
    return [VocabularyFormatter formattedStringForLanguage:language withDictionary:dict];
}


+ (NSString*) formattedStringForLanguage:(VocabularyFormatterLanguage) language withDictionary:(NSDictionary*) dict {
    
    NSString* text = nil;
    NSString* prefix = nil;
    
    if (language == Lang1) {
        
        text = dict[@"textLang1"];
        prefix = dict[@"prefixLang1"];
    }
    else {
        
        text = dict[@"textLang2"];
        prefix = dict[@"prefixLang2"];
    }
    
    NSString* formattedString = [NSString stringWithFormat:@"%@%@",
                                 prefix ? [NSString stringWithFormat:@"%@ ", prefix] : @"",
                                 text
                                 ];
    
    return formattedString;
}


@end
