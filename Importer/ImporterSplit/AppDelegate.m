//
//  AppDelegate.m
//  Importer
//
//  Created by Stefan Ueter on 28.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager2.h"
#import "LogViewController.h"
#import "UniParser.h"

#import "Course.h"
#import "Lesson.h"
#import "Pearl.h"
#import "Vocabulary.h"
#import "DialogLine.h"
#import "ExerciseCluster.h"
#import "Exercise.h"
#import "ExerciseLine.h"

#import "ExerciseTypes.h"




#define GRAMMAR_FILE                @"grammar.txt"
#define DATABASE_NAME               @"content"

#define PARSER_LOGGING_ENABLED      NO

#define LOG_MESSAGE_COLOR           [UIColor blackColor]
#define LOG_ERROR_COLOR             [UIColor redColor]
#define LOG_WARNING_COLOR           [UIColor orangeColor]

#define COURSE_FILE                 @"kurse.csv"
#define LESSON_FILE                 @"lektionen.csv"
#define VOCABULARY_FILE             @"vokabeln.csv"
#define DIALOG_FILE                 @"dialoge.csv"
#define GRAMMAR2_FILE               @"grammar.csv"
#define UEBUNGEN_FILE               @"uebungen.csv"

#define PEARL_ID_RANGE_VOCABULARY       10000000  // 10 million
#define PEARL_ID_RANGE_DIALOG           20000000
#define PEARL_ID_RANGE_GRAMMAR          30000000
#define PEARL_ID_RANGE_REPETITION       40000000


// stores

#define STORE_STRUCTURE         @"structure"
#define STORE_TEASER            @"teaser"
#define STORE_COURSE1           @"course1"
#define STORE_COURSE2           @"course2"
#define STORE_COURSE3           @"course3"
#define STORE_COURSE4           @"course4"

//#define STORE_NAME      @"main"


@interface AppDelegate () {
    
    LogViewController* _logViewController;
    NSString* _grammarString;
    UniParser* _parser;
    uint _errorCount;
    DataManager2* _dataManagerStructure;
    DataManager2* _dataManagerTeaser;
    DataManager2* _dataManagerCourse1;
    DataManager2* _dataManagerCourse2;
    DataManager2* _dataManagerCourse3;
    DataManager2* _dataManagerCourse4;
}

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    NSSetUncaughtExceptionHandler(&HandleExceptions);
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    _logViewController = [[LogViewController alloc] init];
    [self.window setRootViewController:_logViewController];
    
    [self.window makeKeyAndVisible];

// main code part
    
    [self initialize];
    
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"content" ofType:nil];


    [_dataManagerStructure clearAllStores];
    [_dataManagerTeaser clearAllStores];
    [_dataManagerCourse1 clearAllStores];
    [_dataManagerCourse2 clearAllStores];
    [_dataManagerCourse3 clearAllStores];
    [_dataManagerCourse4 clearAllStores];
    
    [self importCSVFileAtPath:[path stringByAppendingPathComponent:COURSE_FILE]];
    [self importCSVFileAtPath:[path stringByAppendingPathComponent:LESSON_FILE]];
    [self importCSVFileAtPath:[path stringByAppendingPathComponent:VOCABULARY_FILE]];
    [self importCSVFileAtPath:[path stringByAppendingPathComponent:DIALOG_FILE]];
    [self importCSVFileAtPath:[path stringByAppendingPathComponent:GRAMMAR2_FILE]];
    [self importCSVFileAtPath:[path stringByAppendingPathComponent:UEBUNGEN_FILE]];

    [_dataManagerStructure test];
    
//    NSArray* lessons = [_dataManagerStructure fetchDataForEntityName:@"Lesson" withPredicate:nil sortedBy:@"id", nil];

    [_dataManagerStructure save];
    [_dataManagerTeaser save];
    [_dataManagerCourse1 save];
    [_dataManagerCourse2 save];
    [_dataManagerCourse3 save];
    [_dataManagerCourse4 save];

    
//    lessons = [_dataManagerStructure fetchDataForEntityName:@"Lesson" withPredicate:nil sortedBy:@"id", nil];
    
    return YES;
}
                               
                               
void HandleExceptions(NSException *exception) {

    NSLog(@"The app has encountered an unhandled exception: %@ (userInfo: %@)", [exception debugDescription], exception.userInfo);
    
}


- (void) initialize {
    
    NSString* grammarPath = GRAMMAR_FILE;
    NSString* grammarPathAbs = [[NSBundle mainBundle] pathForResource:grammarPath ofType:nil];
    _grammarString = [NSString stringWithContentsOfFile:grammarPathAbs encoding:NSUTF8StringEncoding error:nil];
    _parser = [[UniParser alloc] initWithGrammarString:_grammarString];
    _parser.loggingEnabled = PARSER_LOGGING_ENABLED;
    
    _dataManagerStructure = [DataManager2 createInstanceWithName:@"content_structure" modelName:@"contentSplit"];
    _dataManagerTeaser = [DataManager2 createInstanceWithName:@"content_teaser" modelName:@"contentSplit"];
    _dataManagerCourse1 = [DataManager2 createInstanceWithName:@"content_course1" modelName:@"contentSplit"];
    _dataManagerCourse2 = [DataManager2 createInstanceWithName:@"content_course2" modelName:@"contentSplit"];
    _dataManagerCourse3 = [DataManager2 createInstanceWithName:@"content_course3" modelName:@"contentSplit"];
    _dataManagerCourse4 = [DataManager2 createInstanceWithName:@"content_course4" modelName:@"contentSplit"];
    
    [_dataManagerStructure addStoreWithName:STORE_STRUCTURE configuration:@"structure" location:DataManagerStoreLocationDocuments];
    [_dataManagerTeaser addStoreWithName:STORE_TEASER configuration:@"exercises" location:DataManagerStoreLocationDocuments];
    [_dataManagerCourse1 addStoreWithName:STORE_COURSE1 configuration:@"exercises" location:DataManagerStoreLocationDocuments];
    [_dataManagerCourse2 addStoreWithName:STORE_COURSE2 configuration:@"exercises" location:DataManagerStoreLocationDocuments];
    [_dataManagerCourse3 addStoreWithName:STORE_COURSE3 configuration:@"exercises" location:DataManagerStoreLocationDocuments];
    [_dataManagerCourse4 addStoreWithName:STORE_COURSE4 configuration:@"exercises" location:DataManagerStoreLocationDocuments];
}


#pragma mark - Import Exercises from CSV

//- (void) importCSVsFromFolder:(NSString*) folderPath {
//    
//    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:folderPath];
//    NSString* path = nil;
//    
//    while((path = [enumerator nextObject])) {
//        
//        if ([[path pathExtension] isEqualToString:@"csv"]) {
//            
//            if (FILTER_FILE_NAME && ![path isEqualToString:FILTER_FILE_NAME]) continue;
//            
//            [self importCSVFileAtPath:[folderPath stringByAppendingPathComponent:path]];
//        }
//    }
//}


- (void) importCSVFileAtPath:(NSString*) path {
    
    NSLog(@"importing CSV file: %@", path);
    
    
    NSString* contentString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    [self logMessage:@"Importing CSV file: %@", [path lastPathComponent]];
    
    [_parser parseContentString:contentString withMode:UniParserModeValidateAndCapture];
    
//    if (_parser.hasError) {
//        
//        _parser.loggingEnabled = YES;
//        [_parser parseContentString:contentString withMode:UniParserModeValidateOnly];
//        NSLog(@"Error in %@", path);
//    }
    
    NSArray* data = [_parser capturedObjects];
    NSDictionary* dataDict = data[0];
    NSString* typeString = dataDict[@"sheetType"];
    
//    NSLog(@"data: %@", dataDict);
    
    NSLog(@"%@", typeString);
    
    [self handleData:dataDict withSheetType:typeString];
}


- (void) handleData:(NSDictionary*) dataDict withSheetType:(NSString*) sheetType {
    
    if ([sheetType isEqualToString:@"Kurse"]) {
        
        [self handleCourseData:dataDict];
    }
    else if ([sheetType isEqualToString:@"Lektionen"]) {
        
        [self handleLessonData:dataDict];
    }
    else if ([sheetType isEqualToString:@"Vokabeln"]) {
        
        [self handleVocabularyData:dataDict];
    }
    else if ([sheetType isEqualToString:@"Dialoge"]) {
        
        [self handleDialogData:dataDict];
    }
    else if ([sheetType isEqualToString:@"Grammatik"]) {
        
        [self handleGrammarData:dataDict];
    }
    else if ([sheetType isEqualToString:@"Übungen"]) {
        
        [self handleExerciseData:dataDict];
    }
}


- (void) handleCourseData:(NSDictionary*) dataDict {
    
//    $(id)number , separator ,
//    $(title)text , separator ,
//    $(imageFile)text , separator ,
//    [text] ,
//    newline ;
    
    NSUInteger courseID = 0;
    NSString* title;
    NSString* imageFile;
    NSString* photoCredits;
    NSString* photoCreditsTitle;
    
    NSArray* contentArray = dataDict[@"content"];
    
    for (NSDictionary* lineDict in contentArray) {

        if (lineDict[@"id"]) {
            
            courseID = [lineDict[@"id"] integerValue];
        }
        
        title = lineDict[@"title"];
        imageFile = lineDict[@"imageFile"];
        photoCredits = lineDict[@"photoCredits"];
        photoCreditsTitle = lineDict[@"photoCreditsTitle"];
        
        assert(courseID != 0);
        assert(title);
        
        // write to database
        
//        Course* course = [_dataManager insertNewObjectForEntityName:@"Course"];
        Course* course = [_dataManagerStructure insertObjectWithEntityName:@"Course" intoStoreNamed:STORE_STRUCTURE];
        course.id = (int)courseID;
        course.title = title;
        course.imageFile = imageFile;
        course.photoCredits = photoCredits;
        course.photoCreditsTitle = photoCreditsTitle;
        
        // -
        
//        [self logMessage:@"%d, %@, %@", courseID, title, imageFile];
    }
    
}


- (void) handleLessonData:(NSDictionary*) dataDict {
    
//    [ $(courseID)number ] , separator ,
//    text , separator ,
//    $(lessonID)number , separator ,
//    $(lessonTitle)text , separator ,
//    [ $(imageFile)text ] , separator ,
//    [ text ] ,
//    newline ;
    
    NSUInteger courseID = 0;
    NSUInteger lessonID = 0;
    NSString* title;
    NSString* imageFile;
    BOOL isTeaser;
    NSString* photoCredits;
    NSString* photoCreditsTitle;
    
    NSArray* contentArray = dataDict[@"content"];
    
    for (NSDictionary* lineDict in contentArray) {
        
        if (lineDict.allKeys.count == 0) continue;
        
        if (lineDict[@"courseID"]) {
            
            courseID = [lineDict[@"courseID"] integerValue];
        }
        
        lessonID = [lineDict[@"lessonID"] integerValue];
        title = lineDict[@"lessonTitle"];
        imageFile = lineDict[@"imageFile"];
        isTeaser = [lineDict[@"teaser"] isEqualToString:@"yes"];
        photoCredits = lineDict[@"photoCredits"];
        photoCreditsTitle = lineDict[@"photoCreditsTitle"];
        
//        assert(courseID != 0);
//        assert(lessonID != 0);
//        assert(title);

        if (!(
              courseID
              && lessonID
              && title
            )) {
            
            [self logWarning:@"Missing data in line."];
            
            continue;
        }
        
        // write to database

        Course* course = [[_dataManagerStructure fetchDataForEntityName:@"Course" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", courseID] sortedBy:nil] firstObject];
        
//        Lesson* lesson = [_dataManager insertNewObjectForEntityName:@"Lesson"];
        Lesson* lesson = [_dataManagerStructure insertObjectWithEntityName:@"Lesson" intoStoreNamed:STORE_STRUCTURE];
        lesson.id = (int)lessonID;
        lesson.title = title;
        lesson.imageFile = imageFile;
        lesson.course = course;
        lesson.isTeaser = isTeaser;
        lesson.photoCredits = photoCredits;
        lesson.photoCreditsTitle = photoCreditsTitle;
        
        // -

//        [self logMessage:@"%d, %d, %@, %@", courseID, lessonID, title, imageFile];
        
        if (isTeaser) {
            
            NSLog(@"teaser: %@", lesson.title);
        }
    }
    
}


- (void) handleVocabularyData:(NSDictionary*) dataDict {
    
//    [ $(lessonID)number ] , separator ,
//    text , separator ,
//    text , separator ,
//    [ $(chunkID)number ] , separator ,
//    [ $(pearlTitle)text ] , separator ,
//    $(vocabularyID)number , separator ,
//    [ $(prefixLang1)text ] , separator ,
//    [ $(vocabularyLang1) text ] , separator ,
//    [ $(prefixLang2)text ] , separator ,
//    [ $(vocabularyLang2) text ] , separator ,
//    vokabeln_content_line_exclusion_block ,
//    [ $(imageFile)text ] , separator ,
//    [ $(audioFile)text ] , separator ,
//    [ $(popupFile)text ] , separator ,
//    [ text ] ,
//    newline ;
//    
//    
//    @(excludes)vokabeln_content_line_exclusion_block =
//    
//    &set_if2(MATPIC, "1", ( [ "X" | "x" ] , separator ) ) ,
//    &set_if2(SNAKE, "1", ( [ "X" | "x" ] , separator ) ) ,
//    &set_if2(DND, "1", ( [ "X" | "x" ] , separator ) ) ,
//    &set_if2(LTXT_CUSTOM, "1", ( [ "X" | "x" ] , separator ) ) ,
//    &set_if2(SCR, "1", ( [ "X" | "x" ] , separator ) ) ;

    NSUInteger lessonID = 0;
    NSUInteger chunkID = 0;
    NSString* pearlTitle;
    NSUInteger vocabularyID = 0;
    NSString* prefixLang1;
    NSString* vocabularyLang1;
    NSString* prefixLang2;
    NSString* vocabularyLang2;
    NSDictionary* excludes;
    NSString* imageFile;
    NSString* audioFile;
    NSString* popupFile;
    NSString* photoCredits = nil;
    Pearl* pearl = nil;
    Exercise* exercise = nil;
    Exercise* exercise_random_multiple = nil;
//    int lineID = 0;
    int lineID_random_multiple = 0;
//    int clusterID_random_single = 0;
    
    NSString* storeName = nil;
    DataManager2* dataManagerCourse = nil;
    
    
    NSArray* contentArray = dataDict[@"content"];
    
    for (NSDictionary* lineDict in contentArray) {
        
        if (lineDict[@"lessonID"]) {
            
            lessonID = [lineDict[@"lessonID"] integerValue];
        }

        if (lineDict[@"chunkID"]) {

            NSUInteger chunkID_new = [lineDict[@"chunkID"] integerValue];

            // create pearl
            
            if (chunkID_new != chunkID) {
                
                chunkID = chunkID_new;

                pearlTitle = lineDict[@"pearlTitle"];

                Lesson* lesson = [[_dataManagerStructure fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", lessonID] sortedBy:nil] firstObject];

                
                // get the respective datamanager for the lesson
                
                storeName = [self _storeNameForLesson:lesson];
                dataManagerCourse = [self _dataManagerForLesson:lesson];
                
                
                pearl = [_dataManagerStructure insertObjectWithEntityName:@"Pearl" intoStoreNamed:STORE_STRUCTURE];
                pearl.id = PEARL_ID_RANGE_VOCABULARY + (lessonID * 1000) + (int)chunkID;
                pearl.title = pearlTitle;
                pearl.lesson = lesson;
                
                // also create an exercise (and cluster) everytime a pearl is created, to also store vocabularies as an exercise
                
                ExerciseCluster* cluster = [dataManagerCourse insertObjectWithEntityName:@"ExerciseCluster" intoStoreNamed:storeName];
                cluster.id = 10;  // HARD CODED since theres only 1 in this pearl
//                cluster.pearl = pearl;
                cluster.pearlID = pearl.id;
                
                exercise = [dataManagerCourse insertObjectWithEntityName:@"Exercise" intoStoreNamed:storeName];
                exercise.id = 10;  // HARD CODED since theres only 1 in this cluster
                exercise.cluster = cluster;
                exercise.type = VOCABFLOW;
                
                
//                lineID = 10;  // STARTING ID
                
                
                ExerciseLine* line = [dataManagerCourse insertObjectWithEntityName:@"ExerciseLine" intoStoreNamed:storeName];
                line.id = 0;  // hardcoded
                line.field1 = @"vocabularies";
                line.exercise = exercise;
                
//                lineID += 10;
                
                
                // also create an exercise and cluster everytime a pearl is created, for the random_multiple exercise
                
                ExerciseCluster* cluster_random_multiple = [dataManagerCourse insertObjectWithEntityName:@"ExerciseCluster" intoStoreNamed:storeName];
                cluster_random_multiple.id = 20;  // HARD CODED since theres only 1 in this pearl
//                cluster_random_multiple.pearl = pearl;
                cluster_random_multiple.pearlID = pearl.id;
                
                exercise_random_multiple = [dataManagerCourse insertObjectWithEntityName:@"Exercise" intoStoreNamed:storeName];
                exercise_random_multiple.id = 10;  // HARD CODED since theres only 1 in this cluster
                exercise_random_multiple.cluster = cluster_random_multiple;
                exercise_random_multiple.type = RANDOM_VOC_MULTIPLE;
                
                lineID_random_multiple = 10;  // STARTING ID
                
                
//                clusterID_random_single = 30;
            }
            
            // -
        }

        vocabularyID = [lineDict[@"vocabularyID"] integerValue];
        prefixLang1 = lineDict[@"prefixLang1"];
        vocabularyLang1 = lineDict[@"vocabularyLang1"];
        prefixLang2 = lineDict[@"prefixLang2"];
        vocabularyLang2 = lineDict[@"vocabularyLang2"];
        excludes = lineDict[@"excludes"];
        imageFile = lineDict[@"imageFile"];
        audioFile = lineDict[@"audioFile"];
        popupFile = lineDict[@"popupFile"];
        photoCredits = lineDict[@"photoCredits"];
        
        // excludes
        
        // -
        
        assert(lessonID != 0);
        assert(chunkID != 0);
        assert(vocabularyID != 0);
        assert(vocabularyLang1);
        assert(vocabularyLang2);
        
        // write to database
        
        
        Vocabulary* vocabulary = [dataManagerCourse insertObjectWithEntityName:@"Vocabulary" intoStoreNamed:storeName];
        vocabulary.id = (int)vocabularyID;
        vocabulary.prefixLang1 = prefixLang1;
        vocabulary.prefixLang2 = prefixLang2;
        vocabulary.textLang1 = vocabularyLang1;
        vocabulary.textLang2 = vocabularyLang2;
        vocabulary.imageFile = imageFile;
        vocabulary.audioFile = audioFile;
        vocabulary.popupFile = popupFile;
        vocabulary.photoCredits = photoCredits;
//        vocabulary.pearl = pearl;
        vocabulary.pearlID = pearl.id;
        
        // -
        
        // also store vocabularies as an exercise in multiple lines
        
        ExerciseLine* line = [dataManagerCourse insertObjectWithEntityName:@"ExerciseLine" intoStoreNamed:storeName];
//        line.id = lineID;
        line.id = vocabularyID;
        line.field1 = [NSString stringWithFormat:@"%ld", vocabularyID];
        line.exercise = exercise;
        
//        lineID += 10;
        
        
        // also store vocabularies for random_multiple exercise
        
        ExerciseLine* line_random_multiple = [dataManagerCourse insertObjectWithEntityName:@"ExerciseLine" intoStoreNamed:storeName];
        line_random_multiple.id = lineID_random_multiple;
        line_random_multiple.field1 = [NSString stringWithFormat:@"%ld", vocabularyID];
        line_random_multiple.exercise = exercise_random_multiple;
        
        lineID_random_multiple += 10;
        
        
        // also store each vocabulary as a random_single exercise
        
        ExerciseCluster* cluster_random_single = [dataManagerCourse insertObjectWithEntityName:@"ExerciseCluster" intoStoreNamed:storeName];
//        cluster_random_single.id = clusterID_random_single;
        cluster_random_single.id = 300000 + vocabularyID;
//        cluster_random_single.pearl = pearl;
        cluster_random_single.pearlID = pearl.id;
        
        Exercise* exercise_random_single = [dataManagerCourse insertObjectWithEntityName:@"Exercise" intoStoreNamed:storeName];
        exercise_random_single.id = 10;  // HARD CODED since theres only 1 in this cluster
        exercise_random_single.cluster = cluster_random_single;
        exercise_random_single.type = RANDOM_VOC_SINGLE;

        ExerciseLine* line_random_single = [dataManagerCourse insertObjectWithEntityName:@"ExerciseLine" intoStoreNamed:storeName];
        line_random_single.id = 10;
        line_random_single.field1 = [NSString stringWithFormat:@"%ld", vocabularyID];
        line_random_single.exercise = exercise_random_single;

//        clusterID_random_single += 10;

        
        
        
//        [self logMessage:@"%d, %d, %d, %@, %@, %@, %@, %@, %@, %@", lessonID, chunkID, vocabularyID, prefixLang1, vocabularyLang1, prefixLang2, vocabularyLang2, imageFile, audioFile, popupFile];
    }
}


- (void) handleDialogData:(NSDictionary*) dataDict {

//    @dialoge_content_line =
//    
//    [ $(lessonID)number ] , separator ,
//    text , separator ,
//    text , separator ,
//    [ $(dialogID)number ] , separator ,
//    [ $(pearlTitle)text ] , separator ,
//    [ $(speaker)text ] , separator ,
//    $(textLang1)text , separator ,
//    $(textLang2)text , separator ,
//    [ $(vocabularyID)number ] , separator ,
//    [ $(audioFile)text ] , separator ,
//    [ $(popupFile)text ] , separator ,
//    [ text ] ,
//    newline ;
    
    NSInteger lessonID = 0;
    NSInteger pearlID = 0;
    NSString* pearlTitle = nil;
    NSString* speaker = nil;
    NSString* textLang1 = nil;
    NSString* textLang2 = nil;
    NSString* vocabularyIDs = nil;
    NSString* audioFile = nil;
    NSString* audioRange = nil;
    NSString* popupFile = nil;
    Pearl* pearl = nil;
    Exercise* exercise = nil;
    int lineID = 0;
    
    
    NSString* storeName = nil;
    DataManager2* dataManagerCourse = nil;

    
    
    NSArray* contentArray = dataDict[@"content"];
    
    for (NSDictionary* lineDict in contentArray) {
        
        if (lineDict[@"lessonID"]) {
            
            lessonID = [lineDict[@"lessonID"] integerValue];
            pearlID = 0;
        }
        
        if (lineDict[@"speaker"]) {
            
            speaker = lineDict[@"speaker"];
        }

        if (lineDict[@"pearlID"]) {
            
            NSUInteger pearlID_new = [lineDict[@"pearlID"] integerValue];
            
            // create pearl
            
            if (pearlID_new != pearlID) {
                
                pearlID = pearlID_new;
                
                pearlTitle = lineDict[@"pearlTitle"];
                
                Lesson* lesson = [[_dataManagerStructure fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", lessonID] sortedBy:nil] firstObject];
                
                storeName = [self _storeNameForLesson:lesson];
                dataManagerCourse = [self _dataManagerForLesson:lesson];
                
                
                pearl = [_dataManagerStructure insertObjectWithEntityName:@"Pearl" intoStoreNamed:STORE_STRUCTURE];
                pearl.id = PEARL_ID_RANGE_DIALOG + (lessonID * 1000) + (int)pearlID;
                pearl.title = pearlTitle;
                pearl.lesson = lesson;
                
                audioFile = nil;
                
                // also create an exercise (and cluster) everytime a pearl is created, to also store vocabularies as an exercise
                
                ExerciseCluster* cluster = [dataManagerCourse insertObjectWithEntityName:@"ExerciseCluster" intoStoreNamed:storeName];
                cluster.id = 10;  // HARD CODED since theres only 1 in this pearl
//                cluster.pearl = pearl;
                cluster.pearlID = pearl.id;
                
                exercise = [dataManagerCourse insertObjectWithEntityName:@"Exercise" intoStoreNamed:storeName];
                exercise.id = 10;  // HARD CODED since theres only 1 in this cluster
                exercise.cluster = cluster;
                exercise.type = DIALOG;
                
                lineID = 10;  // STARTING ID
            }
            
            // -
        }

        if (lineDict[@"audioFile"]) {
            
            audioFile = lineDict[@"audioFile"];
        }

        
//        dialogID++;  // increase dialogID
        
        vocabularyIDs = lineDict[@"vocabularyIDString"];
        speaker = lineDict[@"speaker"];
        textLang1 = lineDict[@"textLang1"];
        textLang2 = lineDict[@"textLang2"];
        popupFile = lineDict[@"popupFile"];
        audioRange = lineDict[@"audioRange"];
        
        // excludes
        
        // -
        
        assert(lessonID != 0);
        assert(pearlID != 0);
        assert(textLang1);
        assert(textLang2);
//        assert(speaker);  // speaker kann für einleitende Sätze leer sein
        assert(lineID != 0);
//        assert(audioFile);
        
        // write to database
        
        DialogLine* dialogLine = [dataManagerCourse insertObjectWithEntityName:@"DialogLine" intoStoreNamed:storeName];
        dialogLine.id = (int)lineID;
        dialogLine.speaker = speaker;
        dialogLine.textLang1 = textLang1;
        dialogLine.textLang2 = textLang2;
        dialogLine.vocabularyIDs = vocabularyIDs;
        dialogLine.audioFile = audioFile;
        dialogLine.audioRange = audioRange;
        dialogLine.popupFile = popupFile;
        dialogLine.exercise = exercise;
        
        lineID += 10;
        
        // -
        
//        [self logMessage:@"%ld %ld %ld", lessonID, pearl.id, dialogID];
    }
}


- (void) handleGrammarData:(NSDictionary*) dataDict {
    
//    @dialoge_content_line =
//    
//    [ $(lessonID)number ] , separator ,
//    text , separator ,
//    text , separator ,
//    [ $(pearlID)number ] , separator ,
//    [ $(pearlTitle)text ] , separator ,
//    [ $(exerciseID)number ] , separator ,
//    [ $(instruction)text ] , separator ,
//    [ $(topText)text ] , separator ,
//    [ $(field1)text ] , separator ,
//    [ $(field2)text ] , separator ,
//    [ $(field3)text ] , separator ,
//    [ $(field4)text ] , separator ,
//    [ $(field5)text ] , separator ,
//    &set_if2(exerciseType, "LTXT_STANDARD", [ "X" | "x" ]) , separator ,
//    &set_if2(exerciseType, "LTXT_CUSTOM", [ "X" | "x" ]) , separator ,
//    &set_if2(tabular, "1", [ "X" | "x" ]) , separator ,
//    &set_if2(exerciseType, "VOCABFLOW", [ "X" | "x" ]) , separator ,
//    &set_if2(exerciseType, "MATCHER", [ "X" | "x" ]) , separator ,
//    &set_if2(exerciseType, "SNAKE", [ "X" | "x" ]) , separator ,
//    &set_if2(exerciseType, "DND", [ "X" | "x" ]) , separator ,
//    &set_if2(exerciseType, "MCH", [ "X" | "x" ]) , separator ,
//    &set_if2(exerciseType, "SCR", [ "X" | "x" ]) , separator ,
//    [ $(popupFile)text ] , separator ,
//    [ text ] ,
//    newline ;
    
    NSInteger lessonID = 0;
    NSInteger pearlID = 0;
    NSString* pearlTitle = nil;
    NSInteger exerciseClusterID = 0;
    NSInteger exerciseID = 0;
    NSInteger exerciseLineID = 0;
    NSString* field1 = nil;
    NSString* field2 = nil;
    NSString* field3 = nil;
    NSString* field4 = nil;
    NSString* field5 = nil;
    NSString* exerciseTypeString = nil;
    Lesson* lesson = nil;
    Pearl* pearl = nil;
    ExerciseCluster* exerciseCluster = nil;
    Exercise* exercise = nil;
    BOOL needsNewExercise = NO;
    ExerciseType exerciseType = UNKNOWN;
    
    
    NSString* storeName = nil;
    DataManager2* dataManagerCourse = nil;

    
    NSArray* contentArray = dataDict[@"content"];
    
    for (NSDictionary* lineDict in contentArray) {
        
        if (lineDict.allKeys.count == 0) continue;
        
        
        // LESSON CHANGE
        
        if (lineDict[@"lessonID"]) {
            
            NSUInteger lessonID_new = [lineDict[@"lessonID"] integerValue];

            // load lesson from database
            
            if (lessonID_new != lessonID) {
                
                lessonID = lessonID_new;
                
                lesson = [[_dataManagerStructure fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", lessonID] sortedBy:nil] firstObject];
                
                storeName = [self _storeNameForLesson:lesson];
                dataManagerCourse = [self _dataManagerForLesson:lesson];
                
                
                pearlID = 0;
                pearl = nil;
            }
        }
        
        
        // PEARL CHANGE
        
        if (lineDict[@"pearlID"]) {
            
            NSUInteger pearlID_new = [lineDict[@"pearlID"] integerValue];
            
            // create pearl
            
            if (pearlID_new != pearlID) {
                
                pearlID = pearlID_new;
                
                pearlTitle = lineDict[@"pearlTitle"];
                
                pearl = [_dataManagerStructure insertObjectWithEntityName:@"Pearl" intoStoreNamed:STORE_STRUCTURE];
                pearl.id = PEARL_ID_RANGE_GRAMMAR + (lessonID * 1000) + (int)pearlID;
                pearl.title = pearlTitle;
                pearl.lesson = lesson;
                
                exerciseClusterID = 0;
                exerciseCluster = nil;
            }
            
            // -
        }
        
        
        // EXERCISE (CLUSTER) CHANGE
        
        if (lineDict[@"exerciseID"]) {
            
            NSUInteger exerciseClusterID_new = [lineDict[@"exerciseID"] integerValue];
            
            // create exercise cluster
            
            if (exerciseClusterID_new != exerciseClusterID) {
                
                exerciseClusterID = exerciseClusterID_new;

                exerciseCluster = [dataManagerCourse insertObjectWithEntityName:@"ExerciseCluster" intoStoreNamed:storeName];
                exerciseCluster.id = (int)exerciseClusterID;
//                exerciseCluster.pearl = pearl;
                exerciseCluster.pearlID = pearl.id;

                exerciseID = 0;
                exercise = nil;
                exerciseType = UNKNOWN;
                needsNewExercise = YES;
            }
        }

        
        // EXERCISE TYPE CHANGE
        
        if (lineDict[@"exerciseType"]) {

            exerciseTypeString = lineDict[@"exerciseType"];
            BOOL tabular = [lineDict[@"tabular"] boolValue];
            exerciseType = [self exerciseTypeForString:exerciseTypeString tabular:tabular];
            
            needsNewExercise = YES;
        }
        
        
        // NEEDS NEW EXERCISE
        
        if (needsNewExercise) {

            NSString* instruction = lineDict[@"instruction"];
            NSString* explanation = lineDict[@"explanation"];
            NSString* topText = lineDict[@"topText"];
            NSString* popupFile = lineDict[@"popupFile"];

            exercise = [dataManagerCourse insertObjectWithEntityName:@"Exercise" intoStoreNamed:storeName];
            exercise.id = (int)exerciseID;
            exercise.type = (int)exerciseType;
            exercise.instruction = instruction;
            exercise.explanation = explanation;
            exercise.topText = topText;
            exercise.popupFile = popupFile;
            exercise.cluster = exerciseCluster;
            
            exerciseID++;
            exerciseLineID = 0;
            needsNewExercise = NO;
        }

        
        // EXERCISE LINE
        
        field1 = lineDict[@"field1"];
        field2 = lineDict[@"field2"];
        field3 = lineDict[@"field3"];
        field4 = lineDict[@"field4"];
        field5 = lineDict[@"field5"];

        ExerciseLine* line = [dataManagerCourse insertObjectWithEntityName:@"ExerciseLine" intoStoreNamed:storeName];
        line.id = (int)exerciseLineID;
        line.field1 = field1;
        line.field2 = field2;
        line.field3 = field3;
        line.field4 = field4;
        line.field5 = field5;
        line.exercise = exercise;
        
        ++exerciseLineID;

        
        
//        [self logMessage:@"lesson: %d, pearl: %d, cluster: %d, exercise: %d, line: %d, type: %@ == %@", line.exercise.cluster.pearl.lesson.id, line.exercise.cluster.pearl.id, line.exercise.cluster.id, line.exercise.id, line.id, [ExerciseTypes stringForExerciseType:exercise.type], exercise.instruction];
    }
}


- (void) handleExerciseData:(NSDictionary*) dataDict {
    
    //    @uebungen_content_line =
    //
    //    [ $(lessonID)number ] , separator ,
    //    text , separator ,
    //    text , separator ,
    //    [ $(pearlID)number ] , separator ,
    //    [ $(pearlTitle)text ] , separator ,
    //    [ $(exerciseID)number ] , separator ,
    //    [ $(instruction)text ] , separator ,
    //    [ $(topText)text ] , separator ,
    //    [ $(field1)text ] , separator ,
    //    [ $(field2)text ] , separator ,
    //    [ $(field3)text ] , separator ,
    //    [ $(field4)text ] , separator ,
    //    [ $(field5)text ] , separator ,
    //    [ $(audioFile)text ] , separator ,
    //    [ $(audioRange)text ] , separator ,
    //    [ $(popupFile)text ] , separator ,
    //    &set_if2(exerciseType, "LTXT_STANDARD", [ "X" | "x" ]) , separator ,
    //    &set_if2(exerciseType, "LTXT_CUSTOM", [ "X" | "x" ]) , separator ,
    //    &set_if2(exerciseType, "DND", [ "X" | "x" ]) , separator ,
    //    &set_if2(tabular, "1", [ "X" | "x" ]) , separator ,
    //    &set_if2(exerciseType, "MATPIC", [ "X" | "x" ]) , separator ,
    //    &set_if2(exerciseType, "MATCHER", [ "X" | "x" ]) , separator ,
    //    &set_if2(exerciseType, "SNAKE", [ "X" | "x" ]) , separator ,
    //    &set_if2(exerciseType, "MCH", [ "X" | "x" ]) , separator ,
    //    &set_if2(exerciseType, "SCR", [ "X" | "x" ]) , separator ,
    //    [ text ] ,
    //    newline ;
    
    
    NSInteger lessonID = 0;
    NSInteger pearlID = 0;
    NSString* pearlTitle = nil;
    NSInteger exerciseClusterID = 0;
    NSInteger exerciseID = 0;
    NSInteger exerciseLineID = 0;
    NSString* field1 = nil;
    NSString* field2 = nil;
    NSString* field3 = nil;
    NSString* field4 = nil;
    NSString* field5 = nil;
    NSString* exerciseTypeString = nil;
    Lesson* lesson = nil;
    Pearl* pearl = nil;
    ExerciseCluster* exerciseCluster = nil;
    Exercise* exercise = nil;
    BOOL needsNewExercise = NO;
    ExerciseType exerciseType = UNKNOWN;
    
    
    NSString* storeName = nil;
    DataManager2* dataManagerCourse = nil;

    
    NSArray* contentArray = dataDict[@"content"];
    
    for (NSDictionary* lineDict in contentArray) {
        
        if (lineDict.allKeys.count == 0) continue;
        
        
        // LESSON CHANGE
        
        if (lineDict[@"lessonID"]) {
            
            NSUInteger lessonID_new = [lineDict[@"lessonID"] integerValue];
            
            // load lesson from database
            
            if (lessonID_new != lessonID) {
                
                lessonID = lessonID_new;
                
                lesson = [[_dataManagerStructure fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", lessonID] sortedBy:nil] firstObject];
                
                storeName = [self _storeNameForLesson:lesson];
                dataManagerCourse = [self _dataManagerForLesson:lesson];
                
                
                pearlID = 0;
                pearl = nil;
            }
        }
        
        
        // PEARL CHANGE
        
        if (lineDict[@"pearlID"]) {
            
            NSUInteger pearlID_new = [lineDict[@"pearlID"] integerValue];
            
            // create pearl
            
            if (pearlID_new != pearlID) {
                
                pearlID = pearlID_new;
                
                pearlTitle = lineDict[@"pearlTitle"];
                
                pearl = [_dataManagerStructure insertObjectWithEntityName:@"Pearl" intoStoreNamed:STORE_STRUCTURE];
                pearl.id = PEARL_ID_RANGE_REPETITION + (lessonID * 1000) + (int)pearlID;
                pearl.title = pearlTitle;
                pearl.lesson = lesson;
                
                exerciseClusterID = 0;
                exerciseCluster = nil;
            }
            
            // -
        }
        
        
        // EXERCISE (CLUSTER) CHANGE
        
        if (lineDict[@"exerciseID"]) {
            
            NSUInteger exerciseClusterID_new = [lineDict[@"exerciseID"] integerValue];
            
            // create exercise cluster
            
            if (exerciseClusterID_new != exerciseClusterID) {
                
                exerciseClusterID = exerciseClusterID_new;
                
                exerciseCluster = [dataManagerCourse insertObjectWithEntityName:@"ExerciseCluster" intoStoreNamed:storeName];
                exerciseCluster.id = (int)exerciseClusterID;
//                exerciseCluster.pearl = pearl;
                exerciseCluster.pearlID = pearl.id;
                
                exerciseID = 0;
                exercise = nil;
                exerciseType = UNKNOWN;
                needsNewExercise = YES;
            }
        }
        
        
        // EXERCISE TYPE CHANGE
        
        if (lineDict[@"exerciseType"]) {
            
            exerciseTypeString = lineDict[@"exerciseType"];
            BOOL tabular = [lineDict[@"tabular"] boolValue];
            exerciseType = [self exerciseTypeForString:exerciseTypeString tabular:tabular];
            
            needsNewExercise = YES;
        }
        
        
        // NEEDS NEW EXERCISE
        
        if (needsNewExercise) {
            
            NSString* instruction = lineDict[@"instruction"];
            NSString* topText = lineDict[@"topText"];
            NSString* popupFile = lineDict[@"popupFile"];
            NSString* audioFile = lineDict[@"audioFile"];
            NSString* audioRange = lineDict[@"audioRange"];
            
            exercise = [dataManagerCourse insertObjectWithEntityName:@"Exercise" intoStoreNamed:storeName];
            exercise.id = (int)exerciseID;
            exercise.type = (int)exerciseType;
            exercise.instruction = instruction;
            exercise.topText = topText;
            exercise.popupFile = popupFile;
            exercise.audioFile = audioFile;
            exercise.audioRange = audioRange;
            exercise.cluster = exerciseCluster;
            
            exerciseID++;
            exerciseLineID = 0;
            needsNewExercise = NO;
        }
        
        
        // EXERCISE LINE
        
        field1 = lineDict[@"field1"];
        field2 = lineDict[@"field2"];
        field3 = lineDict[@"field3"];
        field4 = lineDict[@"field4"];
        field5 = lineDict[@"field5"];
        
        ExerciseLine* line = [dataManagerCourse insertObjectWithEntityName:@"ExerciseLine" intoStoreNamed:storeName];
        line.id = (int)exerciseLineID;
        line.field1 = field1;
        line.field2 = field2;
        line.field3 = field3;
        line.field4 = field4;
        line.field5 = field5;
        line.exercise = exercise;
        
        ++exerciseLineID;
        
        
        
//        [self logMessage:@"lesson: %d, pearl: %d, cluster: %d, exercise: %d, line: %d, type: %@ == %@", line.exercise.cluster.pearl.lesson.id, line.exercise.cluster.pearl.id, line.exercise.cluster.id, line.exercise.id, line.id, [ExerciseTypes stringForExerciseType:exercise.type], exercise.instruction];
    }
}



// ##############################################################################

//- (void) handleExerciseData2:(NSDictionary*) dataDict {
//    
////    @uebungen_content_line =
////    
////    [ $(lessonID)number ] , separator ,
////    text , separator ,
////    text , separator ,
////    [ $(pearlID)number ] , separator ,
////    [ $(pearlTitle)text ] , separator ,
////    [ $(exerciseID)number ] , separator ,
////    [ $(instruction)text ] , separator ,
////    [ $(topText)text ] , separator ,
////    [ $(field1)text ] , separator ,
////    [ $(field2)text ] , separator ,
////    [ $(field3)text ] , separator ,
////    [ $(field4)text ] , separator ,
////    [ $(field5)text ] , separator ,
////    [ $(audioFile)text ] , separator ,
////    [ $(audioRange)text ] , separator ,
////    [ $(popupFile)text ] , separator ,
////    &set_if2(exerciseType, "LTXT_STANDARD", [ "X" | "x" ]) , separator ,
////    &set_if2(exerciseType, "LTXT_CUSTOM", [ "X" | "x" ]) , separator ,
////    &set_if2(exerciseType, "DND", [ "X" | "x" ]) , separator ,
////    &set_if2(tabular, "1", [ "X" | "x" ]) , separator ,
////    &set_if2(exerciseType, "MATPIC", [ "X" | "x" ]) , separator ,
////    &set_if2(exerciseType, "MATCHER", [ "X" | "x" ]) , separator ,
////    &set_if2(exerciseType, "SNAKE", [ "X" | "x" ]) , separator ,
////    &set_if2(exerciseType, "MCH", [ "X" | "x" ]) , separator ,
////    &set_if2(exerciseType, "SCR", [ "X" | "x" ]) , separator ,
////    [ text ] ,
////    newline ;
//    
//    NSInteger lessonID = 0;
//    NSInteger pearlID = 0;
//    NSString* pearlTitle = nil;
//    NSInteger exerciseID = 0;
//    NSString* instruction = nil;
//    NSString* topText = nil;
//    NSString* field1 = nil;
//    NSString* field2 = nil;
//    NSString* field3 = nil;
//    NSString* field4 = nil;
//    NSString* field5 = nil;
//    NSString* exerciseTypeString = nil;
//    BOOL tabular = NO;
//    NSString* popupFile = nil;
//    NSString* audioFile = nil;
//    NSString* audioRange = nil;
//    Pearl* pearl = nil;
//    
//    NSArray* contentArray = dataDict[@"content"];
//    
//    for (NSDictionary* lineDict in contentArray) {
//        
//        if (lineDict.allKeys.count == 0) continue;
//        
//        if (lineDict[@"lessonID"]) {
//            
//            lessonID = [lineDict[@"lessonID"] integerValue];
//            pearlID = 0;
//            pearl = nil;
//        }
//        
//        if (lineDict[@"pearlID"]) {
//            
//            NSUInteger pearlID_new = [lineDict[@"pearlID"] integerValue];
//            
//            // create pearl
//            
//            if (pearlID_new > pearlID) {
//                
//                pearlID = pearlID_new;
//                
//                pearlTitle = lineDict[@"pearlTitle"];
//                
//                Lesson* lesson = [[_dataManager fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", lessonID] sortedBy:nil] firstObject];
//                
//                assert(lesson);
//                
//                pearl = [_dataManager insertNewObjectForEntityName:@"Pearl"];
//                pearl.id = (int)pearlID;
//                pearl.title = pearlTitle;
//                pearl.lesson = lesson;
//                
//                exerciseID = 0;
//            }
//            
//            // -
//        }
//        
//        if (lineDict[@"exerciseID"]) {
//            
//            NSUInteger exerciseID_new = [lineDict[@"exerciseID"] integerValue];
//            
//            // create exercise
//            
//            if (exerciseID_new > exerciseID) {
//                
//                exerciseID = exerciseID_new;
//                
//                exerciseTypeString = nil;
//            }
//        }
//        
//        
//        if (lineDict[@"exerciseType"]) {
//            
//            NSString* exerciseTypeString_new = lineDict[@"exerciseType"];
//            
//            // create exercise
//            
//            if (![exerciseTypeString_new isEqualToString:exerciseTypeString]) {
//                
//                exerciseTypeString = exerciseTypeString_new;
//            }
//        }
//        
//        if (lineDict[@"audioFile"]) {
//            
//            audioFile = lineDict[@"audioFile"];
//        }
//
//        
//        instruction = lineDict[@"instruction"];
//        topText = lineDict[@"topText"];
//        field1 = lineDict[@"field1"];
//        field2 = lineDict[@"field2"];
//        field3 = lineDict[@"field3"];
//        field4 = lineDict[@"field4"];
//        field5 = lineDict[@"field5"];
//        tabular = [lineDict[@"tabular"] boolValue];
//        popupFile = lineDict[@"popupFile"];
//        audioRange = lineDict[@"audioRange"];
//        
//        
////        assert(exerciseTypeString && exerciseTypeString.length > 0);
//        
//        ExerciseType exerciseType = [self exerciseTypeForString:exerciseTypeString tabular:tabular];
//        
//        assert(lessonID != 0);
//        assert(pearlID != 0);
//        assert(pearl);
//        assert(exerciseID != 0);
////        assert(exerciseType != UNKNOWN);
//        
//        // write to database
//        
////        Exercise* exercise = [_dataManager insertNewObjectForEntityName:@"Exercise"];
////        exercise.id = (int)exerciseID;
////        exercise.type = exerciseType;
////        exercise.instruction = instruction;
////        exercise.topText = topText;
////        exercise.field1 = field1;
////        exercise.field2 = field2;
////        exercise.field3 = field3;
////        exercise.field4 = field4;
////        exercise.field5 = field5;
////        exercise.popupFile = popupFile;
////        exercise.audioFile = audioFile;
////        exercise.audioRange = audioRange;
////        exercise.pearl = pearl;
//        
//        // -
//        
//        //        [self logMessage:@"%ld %ld %ld", lessonID, pearl.id, dialogID];
//    }
//}


- (ExerciseType) exerciseTypeForString:(NSString*) string tabular:(BOOL) tabular {
    
    ExerciseType type = UNKNOWN;
    
    if ([string isEqualToString:@"LTXT_STANDARD"]) {
        
        if (tabular) {
            
            type = LTXT_STANDARD_TABULAR;
        }
        else {
            
            type = LTXT_STANDARD;
        }
    }
    else if ([string isEqualToString:@"LTXT_CUSTOM"]) {
        
        if (tabular) {
            
            type = LTXT_CUSTOM_TABULAR;
        }
        else {
            
            type = LTXT_CUSTOM;
        }
    }
    else if ([string isEqualToString:@"DND"]) {
        
        if (tabular) {
            
            type = DND_TABULAR;
        }
        else {
            
            type = DND;
        }
    }
    else if ([string isEqualToString:@"VOCABFLOW"]) {
        
        if (tabular) {
            
            type = UNKNOWN;
        }
        else {
            
            type = VOCABFLOW;
        }
    }
    else if ([string isEqualToString:@"MATPIC"]) {
        
        if (tabular) {
            
            type = UNKNOWN;
        }
        else {
            
            type = MATPIC;
        }
    }
    else if ([string isEqualToString:@"MATCHER"]) {
        
        if (tabular) {
            
            type = UNKNOWN;
        }
        else {
            
            type = MATCHER;
        }
    }
    else if ([string isEqualToString:@"SNAKE"]) {
        
        if (tabular) {
            
            type = UNKNOWN;
        }
        else {
            
            type = SNAKE;
        }
    }
    else if ([string isEqualToString:@"SCR"]) {
        
        if (tabular) {
            
            type = UNKNOWN;
        }
        else {
            
            type = SCR;
        }
    }
    else if ([string isEqualToString:@"MCH"]) {
        
        if (tabular) {
            
            type = UNKNOWN;
        }
        else {
            
            type = MCH;
        }
    }

    
    return type;
}




#pragma mark - StoreName for Course

- (NSString*) _storeNameForLesson:(Lesson*) lesson {
    
//    return STORE_COURSE1;
    
    
    if (lesson.isTeaser) {
        
        return STORE_TEASER;
    }
    else {
    
        switch (lesson.course.id) {
                
            case 10:
                return STORE_COURSE1;
                break;
                
            case 20:
                return STORE_COURSE2;
                break;
                
            case 30:
                return STORE_COURSE3;
                break;
                
            case 40:
                return STORE_COURSE4;
                break;
                
            default:
                return nil;
                break;
        }
    }
}


- (DataManager2*) _dataManagerForLesson:(Lesson*) lesson {
    
    //    return STORE_COURSE1;
    
    if (lesson.isTeaser) {
        
        return _dataManagerTeaser;
    }
    else {
    
        switch (lesson.course.id) {
                
            case 10:
                return _dataManagerCourse1;
                break;
                
            case 20:
                return _dataManagerCourse2;
                break;
                
            case 30:
                return _dataManagerCourse3;
                break;
                
            case 40:
                return _dataManagerCourse4;
                break;
                
            default:
                return nil;
                break;
        }
    }
}



#pragma mark - Logging


- (void) logMessage:(NSString*) format, ... {
    
    va_list args;
    va_start(args, format);
    
    NSString* string = [[NSString alloc] initWithFormat:format arguments:args];
    
    [self logString:string withColor:LOG_MESSAGE_COLOR];
}


- (void) logError:(NSString*) format, ... {
    
    va_list args;
    va_start(args, format);
    
    NSString* string = [[NSString alloc] initWithFormat:format arguments:args];
    
    [self logString:string withColor:LOG_ERROR_COLOR];
    
    ++_errorCount;
}


- (void) logWarning:(NSString*) format, ... {
    
    va_list args;
    va_start(args, format);
    
    NSString* string = [[NSString alloc] initWithFormat:format arguments:args];
    
    [self logString:string withColor:LOG_WARNING_COLOR];
    
    ++_errorCount;
}


- (void) logString:(NSString*) string withColor:(UIColor*) color {
    
    NSLog(@"[Log] %@", string);
    
    [_logViewController addEntry:string withColor:color];
}


- (void) logSeparator {
    
}



@end
