//
//  VocabularyFormatter.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 16.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vocabulary.h"


typedef NS_ENUM(NSInteger, VocabularyFormatterLanguage) {
    
    Lang1,
    Lang2
};


@interface VocabularyFormatter : NSObject


+ (NSString*) formattedStringForLanguage:(VocabularyFormatterLanguage) language withVocabulary:(Vocabulary*) vocabulary;

+ (NSString*) formattedStringForLanguage:(VocabularyFormatterLanguage) language withDictionary:(NSDictionary*) dict;

@end
