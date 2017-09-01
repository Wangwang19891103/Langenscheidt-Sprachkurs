//
//  DatabaseDumperHTML.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 11.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentDataManager.h"


@interface DatabaseDumperHTML : NSObject {
    
    ContentDataManager* _contentDataManager;
    
    NSMutableString* _htmlString;
    
    // count
    
    int _countCourses;
    int _countLessons;
    int _countPearls;
    int _countClusters;
    int _countExercises;
}


+ (instancetype) instance;

- (void) dump;

@end
