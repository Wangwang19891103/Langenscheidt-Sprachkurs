//
//  DefaultPearlTitle.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "PearlTitle.h"
#import "ContentDataManager.h"
#import "Lesson.h"

#define PEARL_ID_RANGE_VOCABULARY       10000000  // 10 million
#define PEARL_ID_RANGE_DIALOG           20000000
#define PEARL_ID_RANGE_GRAMMAR          30000000


@implementation PearlTitle

+ (NSString*) titleForPearl:(Pearl*) pearl {
 
    // case 0: already has a title
    
    if (pearl.title.length > 0) {
        
        return pearl.title;
    }
    
    // case 1: is a vocabulary pearl
    
    BOOL isVocabularyPearl = (pearl.id >= 10000000 && pearl.id < 20000000);
    BOOL isDialogPearl = (pearl.id >= 20000000 && pearl.id < 30000000);
    
    
    if (isVocabularyPearl) {
    
        Lesson* lesson = pearl.lesson;
//        NSArray* sisterPearls = [[[ContentDataManager instance] dataManager] fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"lesson == %@ AND vocabularies.@count != 0", lesson] sortedBy:@"id", nil];

        NSArray* sisterPearls = [[[ContentDataManager instance] dataManager] fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"lesson == %@ AND id >= 10000000 AND id < 20000000", lesson] sortedBy:@"id", nil];

        
        if (sisterPearls.count == 1) {  // case: only 1 vocabulary pearl in lesson
            
            return @"Vokabeln";  // no number
        }
        else {
            
            NSInteger index = [sisterPearls indexOfObject:pearl];
            NSInteger number = index + 1;
            
            return [NSString stringWithFormat:@"Vokabeln %ld", number];
        }
    }
    
    // case 2: is a dialog pearl
    
    
    else if (isDialogPearl) {
        
        Lesson* lesson = pearl.lesson;
        NSArray* sisterPearls = [[ContentDataManager instance] dialogPearlsForLesson:lesson];
        
        NSInteger index = [sisterPearls indexOfObject:pearl];
        NSInteger number = index + 1;
        
        if (sisterPearls.count > 1) {
            
            return [NSString stringWithFormat:@"Dialog %ld", number];
        }
        else {
            
            return @"Dialog";
        }
    }
    
    else return @"<no title>";
}

@end
