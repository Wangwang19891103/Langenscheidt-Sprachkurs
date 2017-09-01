//
//  AppDelegate.m
//  ContentSplitter
//
//  Created by Stefan Ueter on 10.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "AppDelegate.h"
//#import "ContentDataManager.h"
#import "ExerciseTypes.h"
#import "SSZipArchive.h"
#import "LogManager.h"
#import "ExerciseTypes.h"


#define SOURCE_FOLDER_POPUPS                            [[NSBundle mainBundle] pathForResource:@"Popups" ofType:nil]
#define SOURCE_FOLDER_VOCABULARY_IMAGES_LARGE           [[NSBundle mainBundle] pathForResource:@"Photos/large" ofType:nil]
#define SOURCE_FOLDER_VOCABULARY_IMAGES_SMALL           [[NSBundle mainBundle] pathForResource:@"Photos/small" ofType:nil]
#define SOURCE_FOLDER_VOCABULARY_AUDIOS                 [[NSBundle mainBundle] pathForResource:@"Vocabularies" ofType:nil]
#define SOURCE_FOLDER_DIALOG_AUDIOS                     [[NSBundle mainBundle] bundlePath]
#define SOURCE_FOLDER_DATABASES                         [[NSBundle mainBundle] bundlePath]

#define DESTINATION_FOLDER_POPUPS                       @"popups"
#define DESTINATION_FOLDER_VOCABULARY_IMAGES_LARGE      @"images/vocabularies/large"
#define DESTINATION_FOLDER_VOCABULARY_IMAGES_SMALL      @"images/vocabularies/small"
#define DESTINATION_FOLDER_VOCABULARY_AUDIOS            @"audios/vocabularies"
#define DESTINATION_FOLDER_DIALOG_AUDIOS                @"audios/dialog"
#define DESTINATION_FOLDER_DATABASE                     @"database"

#define DESTINATION_DATABASE_FILENAME                   @"content.sqlite"

#define ZIP_FOLDER_NAME                                 @"zips"

#define PERFORM_COPY        YES
#define PERFORM_ZIP         YES


#define ZIP_COURSE01        @"english_course_01.zip"
#define ZIP_COURSE02        @"english_course_02.zip"
#define ZIP_COURSE03        @"english_course_03.zip"
#define ZIP_COURSE04        @"english_course_04.zip"

#define DESTINATION_FOLDER_TEASER       @"teaser"
#define DESTINATION_FOLDER_COURSE01     @"course01"
#define DESTINATION_FOLDER_COURSE02     @"course02"
#define DESTINATION_FOLDER_COURSE03     @"course03"
#define DESTINATION_FOLDER_COURSE04     @"course04"




// data that needs to be split into 4 course folders:
// - vocabulary images (large, small)
// - vocabulary audios
// - popup files (html)
// - dialog audios

// data files CAN be redundant across multiple courses. resources must be retrieved from its own course folder

// logic:
// - iterate courses
// - iterate exercises
// - look for resources and copy them into the course folder


@interface AppDelegate () {

    NSURL* _currentCourseFolder;
    NSURL* _teaserContentFolder;
    BOOL _currentLessonIsTeaser;
 
    
}

@end



@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    _logCounter = 1;
    
    [self initializeDataManager];
    
    [self _splitContent];
    
    [[LogManager instanceNamed:@"dialogs"] writeLogToFile];
    
    NSLog(@"donezo");
    
    return YES;
}



#pragma mark - Initialize Data Manager

- (void) initializeDataManager {
    
    _dataManager = [DataManager2 createInstanceWithName:@"content" modelName:@"contentSplit"];
    
    [_dataManager addStoreWithName:@"structure" configuration:@"structure" location:DataManagerStoreLocationBundle];
    [_dataManager addStoreWithName:@"teaser" configuration:@"exercises" location:DataManagerStoreLocationBundle];
    [_dataManager addStoreWithName:@"course1" configuration:@"exercises" location:DataManagerStoreLocationBundle];
    [_dataManager addStoreWithName:@"course2" configuration:@"exercises" location:DataManagerStoreLocationBundle];
    [_dataManager addStoreWithName:@"course3" configuration:@"exercises" location:DataManagerStoreLocationBundle];
    [_dataManager addStoreWithName:@"course4" configuration:@"exercises" location:DataManagerStoreLocationBundle];
}



#pragma mark - Fetch Methods

- (NSArray*) _courses {
    
    return [_dataManager fetchDataForEntityName:@"Course" withPredicate:nil sortedBy:@"id", nil];
}


- (NSArray*) _lessonsForCourse:(Course*) course {
    
    return [_dataManager fetchDataForEntityName:@"Lesson" withPredicate:[NSPredicate predicateWithFormat:@"course == %@", course] sortedBy:@"id", nil];
}


- (NSArray*) _pearlsForLesson:(Lesson*) lesson {
    
    return [_dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"lesson == %@", lesson] sortedBy:@"id", nil];
}


- (NSArray*) _vocabulariesForPearl:(Pearl*) pearl {
    
    return [_dataManager fetchDataForEntityName:@"Vocabulary" withPredicate:[NSPredicate predicateWithFormat:@"pearlID == %d", pearl.id] sortedBy:@"id", nil];
}


- (NSArray*) _exercisesForPearl:(Pearl*) pearl {
    
    return [_dataManager fetchDataForEntityName:@"Exercise" withPredicate:[NSPredicate predicateWithFormat:@"cluster.pearlID == %d", pearl.id] sortedBy:@"cluster.id", @"id", nil];
}


- (NSArray*) _dialogLinesForExercise:(Exercise*) exercise {
    
    return [_dataManager fetchDataForEntityName:@"DialogLine" withPredicate:[NSPredicate predicateWithFormat:@"exercise == %@", exercise] sortedBy:@"id", nil];
}





#pragma mark - Splitting Content

- (void) _splitContent {

    // prepare teaser folder
    
    _teaserContentFolder = [self recreateContentFolderForTeaserContent];
    [self copyTeaserSQLite];
    
    
    // split courses
    
    NSArray* courses = [self _courses];
    
    for (Course* course in courses) {
    
        _currentCourseFolder = [self recreateContentFolderForCourse:course];
        
        NSString* sqliteFile = [self _sqliteFileForCourse:course];
        [self _handleSQLiteFile:sqliteFile];
        
        [self _splitContentForCourse:course];
        
        [self _zipFoldersForCourse:course];
    }
}


- (void) _zipFoldersForCourse:(Course*) course {
    
    NSURL* zipFolderURL = [[self _contentFolderURL] URLByAppendingPathComponent:ZIP_FOLDER_NAME];
    
    NSError* error;

    
    // create zip folder if it doesnt exist
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:zipFolderURL.path isDirectory:nil]) {
        
        [[NSFileManager defaultManager] createDirectoryAtURL:zipFolderURL withIntermediateDirectories:YES attributes:nil error:&error];
        [self _handleError:error];
    }

    
    NSString* zipFileName = [self _zipFileNameForCourse:course];
    NSString* zipFilePath = [zipFolderURL.path stringByAppendingPathComponent:zipFileName];

    
    // remove zip file if it exists
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath isDirectory:nil]) {
        
        [[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:&error];
        [self _handleError:error];
    }
    NSLog(@"Please find me %@", zipFilePath);

    
//    [SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:_currentCourseFolder.path];
    [SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:_currentCourseFolder.path withPassword:@"weawaLjQ5#?VA={':CHZR@>zycp<7BRYP,<A=m+AS*42Zhu=6T"];
}


- (NSString*) _zipFileNameForCourse:(Course*) course {
    
    NSString* file = nil;
    
    switch (course.id) {
            
        case 10:
            file = ZIP_COURSE01;
            break;
            
        case 20:
            file = ZIP_COURSE02;
            break;
            
        case 30:
            file = ZIP_COURSE03;
            break;
            
        case 40:
            file = ZIP_COURSE04;
            break;
            
        default:
            break;
    }
    
    return file;
}


- (NSString*) _sqliteFileForCourse:(Course*) course {
    
    NSString* file = nil;
    
    switch (course.id) {
        
        case 10:
            file = @"course1.sqlite";
            break;

        case 20:
            file = @"course2.sqlite";
            break;

        case 30:
            file = @"course3.sqlite";
            break;

        case 40:
            file = @"course4.sqlite";
            break;

        default:
            break;
    }
    
    return file;
}


- (void) _splitContentForCourse:(Course*) course {
    
    NSLog(@"course: %@", course.title);
    
    NSArray* lessons = [self _lessonsForCourse:course];
    
    
    for (Lesson* lesson in lessons) {
        
        NSLog(@"lesson: %@ %@", lesson.title, lesson.isTeaser ? @"(teaser)" : @"");
        
        _currentLessonIsTeaser = lesson.isTeaser;  // setting teaser flag for following content
        
        
        NSArray* pearls = [self _pearlsForLesson:lesson];
        
        
        for (Pearl* pearl in pearls) {

            NSLog(@"Pearl: %@", pearl.title);

            
            // vocabularies
            
            NSArray* vocabularies = [self _vocabulariesForPearl:pearl];
            
            for (Vocabulary* vocabulary in vocabularies) {
                
                [self _splitContentForVocabulary:vocabulary];
            }
            
            
            // exercises
            
            NSArray* exercises = [self _exercisesForPearl:pearl];
            
            NSLog(@"%ld exercises", exercises.count);
            
            for (Exercise* exercise in exercises) {
                
                [self _splitContentForExercise:exercise];
            }
        }
    }
}


- (void) _splitContentForVocabulary:(Vocabulary*) vocabulary {
    
    NSString* imageFile = vocabulary.imageFile;
    NSString* audioFile = vocabulary.audioFile;
    NSString* popupFile = vocabulary.popupFile;
    
    if (popupFile) {
        ;
        ;
    }
    
    [self _handleVocabularyImageFile:imageFile];
    [self _handleVocabularyAudioFile:audioFile];
    [self _handlePopupFile:popupFile];
    
    
    // log popup if found
    
    [self _logPopupFile:popupFile forVocabulary:vocabulary];
}


- (void) _splitContentForExercise:(Exercise*) exercise {

    NSString* popupFile = [self _findPopupFileForExercise:exercise];
    NSString* audioFile = exercise.audioFile;
    
    if (popupFile) [self _handlePopupFile:popupFile];
    if (audioFile) [self _handleDialogAudioFile:audioFile];
    
    
    // log popup if found
    
    [self _logPopupFile:popupFile forExercise:exercise];
}



- (void) _logPopupFile:(NSString*) fileName forExercise:(Exercise*) exercise {
    
    
    if (fileName && fileName.length > 0) {
    
    ExerciseCluster* cluster = exercise.cluster;
    Pearl* pearl = [[_dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", cluster.pearlID] sortedBy:nil] firstObject];
    Lesson* lesson = pearl.lesson;
    Course* course = lesson.course;
    
    NSString* string = [NSString stringWithFormat:@"%d: \t %@ \t %@ \t %@ \t %@ \t %@ \t %@",
                        _logCounter,
                        course.title,
                        lesson.title,
                        pearl.title ? [NSString stringWithFormat:@"<Pearl: %@>", pearl.title] : [NSString stringWithFormat:@"<Pearl id=%d>", pearl.id],
                        [NSString stringWithFormat:@"<Cluster id=%d>", cluster.id],
                        [NSString stringWithFormat:@"<Übung: id=%d, type=%@, instruction=%@>", exercise.id, [ExerciseTypes shortStringForExerciseType:exercise.type], exercise.instruction],
                        [NSString stringWithFormat:@"(%@)", fileName]
                        ];
    
    [[LogManager instanceNamed:@"dialogs"] appendStringToLog:string];
        
        ++_logCounter;
    }
}


- (void) _logPopupFile:(NSString*) fileName forVocabulary:(Vocabulary*) vocabulary {
    
   
    if (fileName && fileName.length > 0) {
        
        Pearl* pearl = [[_dataManager fetchDataForEntityName:@"Pearl" withPredicate:[NSPredicate predicateWithFormat:@"id == %d", vocabulary.pearlID] sortedBy:nil] firstObject];
        Lesson* lesson = pearl.lesson;
        Course* course = lesson.course;
        
        NSString* string = [NSString stringWithFormat:@"%d: \t %@ \t %@ \t %@ \t %@ \t %@",
                            _logCounter,
                            course.title,
                            lesson.title,
                            pearl.title ? [NSString stringWithFormat:@"<Pearl: %@>", pearl.title] : [NSString stringWithFormat:@"<Pearl id=%d>", pearl.id],
                            vocabulary.textLang1,
                            [NSString stringWithFormat:@"(%@)", fileName]
                            ];
        
        [[LogManager instanceNamed:@"dialogs"] appendStringToLog:string];
        
        ++_logCounter;
    }
}




#pragma mark - Teaser Content

- (NSURL*) recreateContentFolderForTeaserContent {
    
    NSString* folderName = DESTINATION_FOLDER_TEASER;
    NSURL* folderURL = [[self _contentFolderURL] URLByAppendingPathComponent:folderName isDirectory:YES];
    NSError* error = nil;
    
    
    // remove folder if it exists
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderURL.path isDirectory:nil]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:folderURL error:&error];
        [self _handleError:error];
    }
    
    
    
    // create folder (and intermediate folders)
    
    [[NSFileManager defaultManager] createDirectoryAtURL:folderURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];
    
    
    // create resource sub-folders
    
    NSURL* vocabularyImagesSmallURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_VOCABULARY_IMAGES_SMALL isDirectory:YES];
    NSURL* vocabularyImagesLargeURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_VOCABULARY_IMAGES_LARGE isDirectory:YES];
    NSURL* vocabularyAudiosURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_VOCABULARY_AUDIOS isDirectory:YES];
    NSURL* dialogAudiosURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_DIALOG_AUDIOS isDirectory:YES];
    NSURL* popupsURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_POPUPS isDirectory:YES];
    NSURL* databaseURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_DATABASE isDirectory:YES];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:vocabularyImagesSmallURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:vocabularyImagesLargeURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:vocabularyAudiosURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dialogAudiosURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:popupsURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:databaseURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];
    
    
    return folderURL;
}


- (void) copyTeaserSQLite {

    NSString* file = @"teaser.sqlite";
    NSString* fileBaseName = [file stringByDeletingPathExtension];
    NSString* fileName = [fileBaseName stringByAppendingPathExtension:@"sqlite"];
    NSString* fileSourcePath = [SOURCE_FOLDER_DATABASES stringByAppendingPathComponent:fileName];
    NSString* destFolderPath =  [_teaserContentFolder.path stringByAppendingPathComponent:DESTINATION_FOLDER_DATABASE];
    NSString* destPath = [destFolderPath stringByAppendingPathComponent:DESTINATION_DATABASE_FILENAME];
    
    BOOL destExists;
    
    destExists = [[NSFileManager defaultManager] fileExistsAtPath:destFolderPath];
    if (!destExists) [self _handleMissingDestFolder:destFolderPath];
    
    
    BOOL sourceExists;
    
    sourceExists = [[NSFileManager defaultManager] fileExistsAtPath:fileSourcePath];
    if (!sourceExists) [self _handleMissingSourceFile:fileSourcePath];
    
    
    [self _copyPath:fileSourcePath toPath:destPath];
}



#pragma mark - Find Popup File

- (NSString*) _findPopupFileForExercise:(Exercise*) exercise {
    
    if (exercise.type == DIALOG) {
        
        NSArray* dialogLines = [self _dialogLinesForExercise:exercise];
        
        for (DialogLine* line in dialogLines) {
            
            if (line.popupFile) {
                
                return line.popupFile;
            }
        }
        
        return nil;
    }
    else {
        
        return exercise.popupFile;
    }
    
    return nil;
}




#pragma mark - Handle Resource Files

- (void) _handleVocabularyImageFile:(NSString*) imageFile {
    
    NSURL* destinationSuperFolder = _currentLessonIsTeaser ? _teaserContentFolder : _currentCourseFolder;
    
    
    NSString* imageNameBase = [imageFile stringByDeletingPathExtension];
    NSString* imageNameSmall = [[imageNameBase stringByAppendingString:@"_small"] stringByAppendingPathExtension:@"jpg"];
    NSString* imageNameLarge = [[imageNameBase stringByAppendingString:@"_large"] stringByAppendingPathExtension:@"jpg"];
    
    NSString* imageSmallSourcePath = [SOURCE_FOLDER_VOCABULARY_IMAGES_SMALL stringByAppendingPathComponent:imageNameSmall];
    NSString* imageLargeSourcePath = [SOURCE_FOLDER_VOCABULARY_IMAGES_LARGE stringByAppendingPathComponent:imageNameLarge];
    
    NSString* imageSmallDestFolderPath = [destinationSuperFolder.path stringByAppendingPathComponent:DESTINATION_FOLDER_VOCABULARY_IMAGES_SMALL];
    NSString* imageLargeDestFolderPath = [destinationSuperFolder.path stringByAppendingPathComponent:DESTINATION_FOLDER_VOCABULARY_IMAGES_LARGE];

    
    
    NSString* imageSmallDestPath = [imageSmallDestFolderPath stringByAppendingPathComponent:imageNameSmall];
    NSString* imageLargeDestPath = [imageLargeDestFolderPath stringByAppendingPathComponent:imageNameLarge];


    BOOL destExists;
    
    destExists = [[NSFileManager defaultManager] fileExistsAtPath:imageSmallDestFolderPath];
    if (!destExists) [self _handleMissingDestFolder:imageSmallDestFolderPath];
    
    destExists = [[NSFileManager defaultManager] fileExistsAtPath:imageLargeDestFolderPath];
    if (!destExists) [self _handleMissingDestFolder:imageLargeDestFolderPath];

    
    BOOL sourceExists;
    
    sourceExists = [[NSFileManager defaultManager] fileExistsAtPath:imageSmallSourcePath];
    if (!sourceExists) [self _handleMissingSourceFile:imageSmallSourcePath];

    sourceExists = [[NSFileManager defaultManager] fileExistsAtPath:imageLargeSourcePath];
    if (!sourceExists) [self _handleMissingSourceFile:imageLargeSourcePath];

    
    [self _copyPath:imageSmallSourcePath toPath:imageSmallDestPath];
    [self _copyPath:imageLargeSourcePath toPath:imageLargeDestPath];
    
    
//    NSError* error;
//    BOOL success;
//    
//    success = [[NSFileManager defaultManager] copyItemAtPath:imageSmallSourcePath toPath:imageSmallDestPath error:&error];
//    if (!success) [self _handleError:error];
//
//    success = [[NSFileManager defaultManager] copyItemAtPath:imageLargeSourcePath toPath:imageLargeDestPath error:&error];
//    if (success) [self _handleError:error];
}


- (void) _handleVocabularyAudioFile:(NSString*) audioFile {
    
    NSURL* destinationSuperFolder = _currentLessonIsTeaser ? _teaserContentFolder : _currentCourseFolder;

    
    NSString* audioFileName = [audioFile stringByAppendingPathExtension:@"mp3"];
    NSString* audioSourcePath = [SOURCE_FOLDER_VOCABULARY_AUDIOS stringByAppendingPathComponent:audioFileName];
    NSString* audioDestFolderPath =  [destinationSuperFolder.path stringByAppendingPathComponent:DESTINATION_FOLDER_VOCABULARY_AUDIOS];
    NSString* audioDestPath = [audioDestFolderPath stringByAppendingPathComponent:audioFileName];
    
    BOOL destExists;
    
    destExists = [[NSFileManager defaultManager] fileExistsAtPath:audioDestFolderPath];
    if (!destExists) [self _handleMissingDestFolder:audioDestFolderPath];
    
    
    BOOL sourceExists;
    
    sourceExists = [[NSFileManager defaultManager] fileExistsAtPath:audioSourcePath];
    if (!sourceExists) [self _handleMissingSourceFile:audioSourcePath];

    
    [self _copyPath:audioSourcePath toPath:audioDestPath];
    
//    NSError* error;
//    BOOL success;
//    
//    success = [[NSFileManager defaultManager] copyItemAtPath:audioSourcePath toPath:audioDestPath error:&error];
//    if (!success) [self _handleError:error];
    
}


- (void) _handleDialogAudioFile:(NSString*) audioFile {

    NSURL* destinationSuperFolder = _currentLessonIsTeaser ? _teaserContentFolder : _currentCourseFolder;

    
    NSString* audioFileBaseName = [audioFile stringByDeletingPathExtension];
    NSString* audioFileName = [audioFileBaseName stringByAppendingPathExtension:@"mp3"];
    NSString* audioSourcePath = [SOURCE_FOLDER_DIALOG_AUDIOS stringByAppendingPathComponent:audioFileName];
    NSString* audioDestFolderPath =  [destinationSuperFolder.path stringByAppendingPathComponent:DESTINATION_FOLDER_DIALOG_AUDIOS];
    NSString* audioDestPath = [audioDestFolderPath stringByAppendingPathComponent:audioFileName];
    
    BOOL destExists;
    
    destExists = [[NSFileManager defaultManager] fileExistsAtPath:audioDestFolderPath];
    if (!destExists) [self _handleMissingDestFolder:audioDestFolderPath];
    
    
    BOOL sourceExists;
    
    sourceExists = [[NSFileManager defaultManager] fileExistsAtPath:audioSourcePath];
    if (!sourceExists) [self _handleMissingSourceFile:audioSourcePath];

    
    [self _copyPath:audioSourcePath toPath:audioDestPath];

    
//    NSError* error;
//    BOOL success;
//    
//    success = [[NSFileManager defaultManager] copyItemAtPath:audioSourcePath toPath:audioDestPath error:&error];
//    if (!success) [self _handleError:error];
}


- (void) _handlePopupFile:(NSString*) popupFile {

    if (!popupFile) return;

    
    NSURL* destinationSuperFolder = _currentLessonIsTeaser ? _teaserContentFolder : _currentCourseFolder;

    
    NSString* popupFileBaseName = [popupFile stringByDeletingPathExtension];
    NSString* popupFileName = [popupFileBaseName stringByAppendingPathExtension:@"html"];
    NSString* popupSourcePath = [SOURCE_FOLDER_POPUPS stringByAppendingPathComponent:popupFileName];
    NSString* popupDestFolderPath =  [destinationSuperFolder.path stringByAppendingPathComponent:DESTINATION_FOLDER_POPUPS];
    NSString* popupDestPath = [popupDestFolderPath stringByAppendingPathComponent:popupFileName];
    
    BOOL destExists;
    
    destExists = [[NSFileManager defaultManager] fileExistsAtPath:popupDestFolderPath];
    if (!destExists) [self _handleMissingDestFolder:popupDestFolderPath];
    
    
    BOOL sourceExists;
    
    sourceExists = [[NSFileManager defaultManager] fileExistsAtPath:popupSourcePath];
    if (!sourceExists) [self _handleMissingSourceFile:popupSourcePath];

    
    [self _copyPath:popupSourcePath toPath:popupDestPath];

    
//    NSError* error;
//    BOOL success;
//    
//    success = [[NSFileManager defaultManager] copyItemAtPath:popupSourcePath toPath:popupDestPath error:&error];
//    if (!success) [self _handleError:error];
//
}


- (void) _handleSQLiteFile:(NSString*) file {
    
    NSURL* destinationSuperFolder = _currentLessonIsTeaser ? _teaserContentFolder : _currentCourseFolder;

    
    NSString* fileBaseName = [file stringByDeletingPathExtension];
    NSString* fileName = [fileBaseName stringByAppendingPathExtension:@"sqlite"];
    NSString* fileSourcePath = [SOURCE_FOLDER_DATABASES stringByAppendingPathComponent:fileName];
    NSString* destFolderPath =  [destinationSuperFolder.path stringByAppendingPathComponent:DESTINATION_FOLDER_DATABASE];
    NSString* destPath = [destFolderPath stringByAppendingPathComponent:DESTINATION_DATABASE_FILENAME];
    
    BOOL destExists;
    
    destExists = [[NSFileManager defaultManager] fileExistsAtPath:destFolderPath];
    if (!destExists) [self _handleMissingDestFolder:destFolderPath];
    
    
    BOOL sourceExists;
    
    sourceExists = [[NSFileManager defaultManager] fileExistsAtPath:fileSourcePath];
    if (!sourceExists) [self _handleMissingSourceFile:fileSourcePath];
    
    
    [self _copyPath:fileSourcePath toPath:destPath];
    
    
    //    NSError* error;
    //    BOOL success;
    //
    //    success = [[NSFileManager defaultManager] copyItemAtPath:popupSourcePath toPath:popupDestPath error:&error];
    //    if (!success) [self _handleError:error];
    //
}





#pragma mark - Content Folders

- (NSURL*) _contentFolderURL {
    
    NSURL* documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];

    return documentsDirectory;
}


- (NSURL*) recreateContentFolderForCourse:(Course*) course {
    
    NSString* folderName = [self _destinationFolderForCourse:course];
    NSURL* folderURL = [[self _contentFolderURL] URLByAppendingPathComponent:folderName isDirectory:YES];
    NSError* error;

    
    // remove folder if it exists
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:folderURL.path isDirectory:nil]) {
        
        [[NSFileManager defaultManager] removeItemAtURL:folderURL error:&error];
        [self _handleError:error];
    }
    
    
    
    // create folder (and intermediate folders)
    
    [[NSFileManager defaultManager] createDirectoryAtURL:folderURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];
    
    
    // create resource sub-folders

    NSURL* vocabularyImagesSmallURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_VOCABULARY_IMAGES_SMALL isDirectory:YES];
    NSURL* vocabularyImagesLargeURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_VOCABULARY_IMAGES_LARGE isDirectory:YES];
    NSURL* vocabularyAudiosURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_VOCABULARY_AUDIOS isDirectory:YES];
    NSURL* dialogAudiosURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_DIALOG_AUDIOS isDirectory:YES];
    NSURL* popupsURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_POPUPS isDirectory:YES];
    NSURL* databaseURL = [folderURL URLByAppendingPathComponent:DESTINATION_FOLDER_DATABASE isDirectory:YES];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:vocabularyImagesSmallURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:vocabularyImagesLargeURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];

    [[NSFileManager defaultManager] createDirectoryAtURL:vocabularyAudiosURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];

    [[NSFileManager defaultManager] createDirectoryAtURL:dialogAudiosURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];

    [[NSFileManager defaultManager] createDirectoryAtURL:popupsURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];

    [[NSFileManager defaultManager] createDirectoryAtURL:databaseURL withIntermediateDirectories:YES attributes:nil error:&error];
    [self _handleError:error];

    
    return folderURL;
}


- (NSString*) _destinationFolderForCourse:(Course*) course {
    
    NSString* folder = nil;
    
    switch (course.id) {
            
        case 10:
            folder = DESTINATION_FOLDER_COURSE01;
            break;
            
        case 20:
            folder = DESTINATION_FOLDER_COURSE02;
            break;
            
        case 30:
            folder = DESTINATION_FOLDER_COURSE03;
            break;
            
        case 40:
            folder = DESTINATION_FOLDER_COURSE04;
            break;
            
        default:
            break;
    }
    
    return folder;
}



#pragma mark - Copy Files

- (void) _copyPath:(NSString*) sourcePath toPath:(NSString*) destPath {

    if (!PERFORM_COPY) return;
    
    
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:destPath];
    
    if (!exists) {
    
        NSError* error;
        BOOL success = [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destPath error:&error];
        if (!success) [self _handleError:error];
    }
}




#pragma mark - Handle Error

- (void) _handleError:(NSError*) error {
    
    if (error) {
        
        NSLog(@"%@", error);
        ;
        ;
        ;
        
    }
}


- (void) _handleMissingSourceFile:(NSString*) file {
    
    NSLog(@"Missing source file: %@", file);
    ;
    ;
    
}


- (void) _handleMissingDestFolder:(NSString*) folder {
    
    NSLog(@"Missing destination folder. %@", folder);
    ;
    ;
}



@end
