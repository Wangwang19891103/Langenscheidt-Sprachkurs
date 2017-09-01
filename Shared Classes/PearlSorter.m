//
//  PearlSorter.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "PearlSorter.h"
#import "Pearl.h"
#import "ContentDataManager.h"



#define PEARL_ID_RANGE_VOCABULARY       10000000  // 10 million
#define PEARL_ID_RANGE_DIALOG           20000000
#define PEARL_ID_RANGE_GRAMMAR          30000000



@implementation PearlSorter

+ (NSArray*) sortPearls:(NSArray*) pearls {
    
    NSArray* sortedPearls = [pearls sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        Pearl* pearl1 = (Pearl*)obj1;
        Pearl* pearl2 = (Pearl*)obj2;
        
        typedef NS_ENUM (NSInteger, PearlType) {VOC, DIALOG, NONE};
        
        PearlType type1 = [PearlSorter isVocabularyPearl:pearl1] ? VOC : [PearlSorter isDialogPearl:pearl1] ? DIALOG : NONE;
        PearlType type2 = [PearlSorter isVocabularyPearl:pearl2] ? VOC : [PearlSorter isDialogPearl:pearl2] ? DIALOG : NONE;
        
        if (type1 < type2) return NSOrderedAscending;

        else if (type1 > type2) return NSOrderedDescending;
        
        else {
        
            if (pearl1.id < pearl2.id) return NSOrderedAscending;
            
            else if (pearl1.id > pearl2.id) return NSOrderedDescending;
            
            else return NSOrderedSame;
        }
    }];
    
    return sortedPearls;
}


+ (BOOL) isVocabularyPearl:(Pearl*) pearl {
    
    return (pearl.id >= 10000000 && pearl.id < 20000000);
}


+ (BOOL) isDialogPearl:(Pearl*) pearl {
    
    return (pearl.id >= 20000000 && pearl.id < 30000000);
}

@end
