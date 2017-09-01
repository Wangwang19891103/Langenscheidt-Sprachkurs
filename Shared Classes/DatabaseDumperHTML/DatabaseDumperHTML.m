//
//  DatabaseDumperHTML.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 11.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "DatabaseDumperHTML.h"
#import "ExerciseTypes.h"
#import "PearlTitle.h"


#define EXPORT_FILE_NAME            @"dump.html"



@implementation DatabaseDumperHTML


#pragma mark - Init

+ (instancetype) instance {
    
    static DatabaseDumperHTML* __instance = nil;
    
    @synchronized (self) {
        
        if (!__instance) {
            
            __instance = [[DatabaseDumperHTML alloc] init];
        }
        
        return __instance;
    }
}


- (id) init {
    
    self = [super init];
    
    _contentDataManager = [ContentDataManager instance];
    _htmlString = [NSMutableString string];
    
    return self;
}




#pragma mark - Dump

- (void) dump {
    
    [self _printHTMLBegin];
    
    [self _dumpCourses];

    [self _printSummary];
    
    [self _printHTMLEnd];
    
    [self _saveToFile];
}


- (void) _dumpCourses {
    
    NSArray* courses = [_contentDataManager courses];
    
    [self _printUnorderedListBegin];
    
    for (Course* course in courses) {
        
        [self _dumpCourse:course];
        
//        break;
    }
    
    [self _printUnorderedListEnd];
}


- (void) _dumpCourse:(Course*) course {
    
    ++_countCourses;
    
    NSLog(@"Course: %d, %@", course.id, course.title);
    
    [self _printCourse:course];
    
    NSArray* lessons = [_contentDataManager lessonsForCourse:course];
    
    [self _printUnorderedListBegin];

    for (Lesson* lesson in lessons) {
        
        [self _dumpLesson:lesson];
    }
    
    [self _printUnorderedListEnd];
}


- (void) _dumpLesson:(Lesson*) lesson {
    
    ++_countLessons;
    
    NSLog(@"Lesson: %d, %@", lesson.id, lesson.title);
    
    [self _printLesson:lesson];
    
    NSArray* pearls = [_contentDataManager pearlsForLesson:lesson];

    [self _printUnorderedListBegin];

    for (Pearl* pearl in pearls) {
        
        [self _dumpPearl:pearl];
    }

    [self _printUnorderedListEnd];
}


- (void) _dumpPearl:(Pearl*) pearl {
    
    ++_countPearls;
    
    [self _printPearl:pearl];

    
    NSArray* vocabularies = [_contentDataManager vocabulariesForPearl:pearl];
    
    [self _printUnorderedListBegin];
    
    for (Vocabulary* voc in vocabularies) {
        
        [self _printVocabulary:voc];
    }
    
    
    [self _printUnorderedListEnd];
    
    
    NSArray* clusters = [_contentDataManager exerciseClustersForPearl:pearl];

    [self _printUnorderedListBegin];
    
    for (ExerciseCluster* cluster in clusters) {
        
        [self _dumpExerciseCluster:cluster];
    }

    [self _printUnorderedListEnd];
}


- (void) _dumpExerciseCluster:(ExerciseCluster*) exerciseCluster {
    
    ++_countClusters;
    
    [self _printExerciseCluster:exerciseCluster];

    [self _printUnorderedListBegin];

    NSArray* exercises = [_contentDataManager exercisesForExerciseCluster:exerciseCluster];
    
    for (Exercise* exercise in exercises) {
        
        ++_countExercises;
        
        [self _printExercise:exercise];
    }

    [self _printUnorderedListEnd];
}



#pragma mark - Print

- (void) _printCourse:(Course*) course {
    
    NSString* string = [NSString stringWithFormat:@"<li><span class='caption'>COURSE</span> ("
                        "id: <span class='value'>%d</span>, "
                        "title: <span class='value'>%@</span>, "
                        "imageFile: <span class='value'>%@</span>, "
                        "count: <span class='count'>%ld</span>"
                        ")</li>",
                        course.id,
                        course.title,
                        course.imageFile,
                        course.lessons.count
                        ];
    
    [self _appendLine:string];
}


- (void) _printLesson:(Lesson*) lesson {

    NSString* string = [NSString stringWithFormat:@"<li><span class='caption'>LESSON</span> ("
                        "id: <span class='value'>%d</span>, "
                        "title: <span class='value'>%@</span>, "
                        "imageFile: <span class='value'>%@</span>, "
                        "count: <span class='count'>%ld</span>"
                        ")</li>",
                        lesson.id,
                        lesson.title,
                        lesson.imageFile,
                        lesson.pearls.count
                        ];
    
    [self _appendLine:string];
}


- (void) _printPearl:(Pearl*) pearl {
    
    NSString* string = [NSString stringWithFormat:@"<li><span class='caption'>PEARL</span> ("
                        "id: <span class='value'>%d</span>, "
                        "title: <span class='value'>%@</span>, "
                        "count: <span class='count'>%ld</span>"
                        ")</li>",
                        pearl.id,
                        [PearlTitle titleForPearl:pearl],
                        [[_contentDataManager exerciseClustersForPearl:pearl] count]
                        ];
    
    [self _appendLine:string];
}


- (void) _printExerciseCluster:(ExerciseCluster*) exerciseCluster {
    
    NSString* string = [NSString stringWithFormat:@"<li><span class='caption'>EXERCISECLUSTER</span> ("
                        "id: <span class='value'>%d</span>, "
                        "pearlID: <span class='value'>%d</span>, "
                        "count: <span class='count'>%ld</span>"
                        ")</li>",
                        exerciseCluster.id,
                        exerciseCluster.pearlID,
                        exerciseCluster.exercises.count
                        ];
    
    [self _appendLine:string];
}


- (void) _printExercise:(Exercise*) exercise {
    
    NSString* string = [NSString stringWithFormat:@"<li><span class='caption'>EXERCISE</span> ("
                        "id: <span class='value'>%d</span>, "
                        "type: <span class='value'>%@</span>, "
                        ")</li>",
                        exercise.id,
                        [ExerciseTypes shortStringForExerciseType:exercise.type]
                        ];
    
    [self _appendLine:string];
}


- (void) _printVocabulary:(Vocabulary*) vocabulary {
    
    NSString* string = [NSString stringWithFormat:@"<li><span class='caption'>VOCABULARY</span> ("
                        "id: <span class='value'>%d</span>, "
                        "text lang1: <span class='value'>%@</span>, "
                        "pearlID: <span class='value'>%d</span>, "
                        ")</li>",
                        vocabulary.id,
                        vocabulary.textLang1,
                        vocabulary.pearlID
                        ];
    
    [self _appendLine:string];
}



- (void) _printUnorderedListBegin {
    
    [self _appendLine:@"<ul>"];
}


- (void) _printUnorderedListEnd {
    
    [self _appendLine:@"</ul>"];
}


- (void) _printHTMLBegin {
    
    [self _appendLine:@"<html>"];
    [self _appendString:@"<head>\n"
     "<style>\n"
     "body { font-family: Helvetica; font-size: 14px; }\n"
     "ul { list-style-type:none; }\n"
     "span.caption { font-weight: bold; }\n"
     "span.value { color: blue; }\n"
     "span.count { color: red; }\n"
     "</style>\n"
     "</head>\n"
     ];
     
    [self _appendLine:@"<body>"];
}


- (void) _printHTMLEnd {
    
    [self _appendLine:@"</body>"];
    [self _appendLine:@"</html>"];
}


- (void) _printSummary {
    
    [self _appendLine:@"<br/><br/>"];
    [self _appendLine:@"Summary:"];
    [self _appendLine:[NSString stringWithFormat:@"Courses: %d", _countCourses]];
    [self _appendLine:[NSString stringWithFormat:@"Lessons: %d", _countLessons]];
    [self _appendLine:[NSString stringWithFormat:@"Pearls: %d", _countPearls]];
    [self _appendLine:[NSString stringWithFormat:@"ExerciseClusters: %d", _countClusters]];
    [self _appendLine:[NSString stringWithFormat:@"Exercises: %d", _countExercises]];


}



#pragma mark - Append String


- (void) _appendLine:(NSString*) string {
    
    [_htmlString appendFormat:@"%@\n", string];
}


- (void) _appendString:(NSString*) string {
    
    [_htmlString appendString:string];
}




#pragma mark - Save to file

- (void) _saveToFile {
    
    NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL* fileURL = [documentsDirectory URLByAppendingPathComponent:EXPORT_FILE_NAME];
    NSError* error;
    
    [_htmlString writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        
        
    }
}


@end
