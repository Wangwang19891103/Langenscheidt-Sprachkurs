//
//  ContentManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 12.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ContentManager.h"
#import "ContentManagerInstallPopupController.h"
#import "SSZipArchive.h"
#import "UserDataManager.h"
#import "SubscriptionManager.h"
#import "ShopPopupViewController.h"


#define CONTENT_DICT_FILE           @"content.plist"

#define CONTENT_DATA_DIRECTORY       @"ContentData"

#define TEASER_CONTENT_DIRECTORY        @"teaser"

#define FOLDER_IMAGES_VOCABULARIES_LARGE        @"images/vocabularies/large"
#define FOLDER_IMAGES_VOCABULARIES_SMALL        @"images/vocabularies/small"
#define FOLDER_AUDIOS_VOCABULARIES              @"audios/vocabularies"
#define FOLDER_POPUPS                           @"popups"
#define FOLDER_AUDIOS_DIALOG                    @"audios/dialog"



//#define CHECK_CONTENT_IN_BUNDLE         // uncomment to activate




@implementation ContentManager


#pragma mark - Init

+ (instancetype) instance {
    
    static ContentManager* __instance = nil;
    
    @synchronized (self) {
        
        if (!__instance) {
            
            __instance = [[ContentManager alloc] init];
        }
        
        return __instance;
    }
}


- (id) init {
    
    self = [super init];
    
    _contentDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CONTENT_DICT_FILE ofType:nil]];
    _settingsManager = [SettingsManager instanceNamed:@"content"];
    self.observers = [NSMutableArray array];
    
    _subscriptionsEnabled = YES;
    
    if ([[SettingsManager instanceNamed:@"dev"] valueForKey:@"subscriptionsEnabled"]) {
        
        _subscriptionsEnabled = [[[SettingsManager instanceNamed:@"dev"] valueForKey:@"subscriptionsEnabled"] boolValue];
    }

    
#ifdef CHECK_CONTENT_IN_BUNDLE
    
    [self _checkContentInBundle];
    
#endif

    
    return self;
}



#pragma mark - Public Methods

#pragma mark Available Content

- (ContentManagerContentAvailabilityStatus) contentAvailabilityStatusForLesson:(Lesson *)lesson {
    
    if (lesson.isTeaser)  {
        
        return ContentManagerContentAvailabilityStatusAvailable;
    }
    
    else {
    
        BOOL existingActiveSubscription = [self _existingActiveSubscription];
        BOOL contentInstalled = [self _contentInstalledForCourse:lesson.course];
        
        if (!existingActiveSubscription) {
            
            return ContentManagerContentAvailabilityStatusNoSubscription;
        }
        else if (!contentInstalled) {
            
            return ContentManagerContentAvailabilityStatusNotInstalled;
        }
        else {
            
            return ContentManagerContentAvailabilityStatusAvailable;
        }
    }
}


//- (ContentManagerContentAvailabilityStatus) contentAvailabilityStatusForLesson:(Lesson*) lesson {
//    
//    return [self contentAvailabilityStatusForCourse:lesson.course];
//}


- (BOOL) contentInstalledForLesson:(Lesson*) lesson {
    
    return [self contentAvailabilityStatusForLesson:lesson] != ContentManagerContentAvailabilityStatusNotInstalled;
}



#pragma mark Subscription

- (void) openShopPopupWithParentViewController:(UIViewController*) parentViewController {
    
    ShopPopupViewController* controller = [[ShopPopupViewController alloc] init];
    
//    _parentViewController = parentViewController;
    
    __weak UIViewController* weakController = parentViewController;
    
    controller.closeBlock = ^{
      
        [weakController dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    
    [parentViewController presentViewController:controller animated:YES completion:^{
        
        
    }];
}








#pragma mark Available Content Stores

- (NSArray*) availableCourseStorePaths {
    
    NSMutableArray* courseStorePaths = [NSMutableArray array];
    
    for (NSDictionary* courseDict in _contentDict[@"courses"]) {
        
        int32_t courseID = (int32_t)[courseDict[@"id"] integerValue];
        BOOL courseInstalled = [self _courseInstalledWithID:courseID];
        
        if (courseInstalled) {
            
            NSString* folderName = courseDict[@"folderName"];
            NSString* fullPath = [self _fullPathToCourseFolderWithName:folderName];
            NSString* fullStorePath = [[[fullPath stringByAppendingPathComponent:@"database"] stringByAppendingPathComponent:@"content"] stringByAppendingPathExtension:@"sqlite"];
            
            [courseStorePaths addObject:fullStorePath];
        }
    }
    
    return courseStorePaths;
}




#pragma mark Install new content


- (void) installContentForLesson:(Lesson *)lesson parentViewController:(UIViewController*)parentViewController {
    
    _course = lesson.course;
    _parentViewController = parentViewController;
    
    [self _showPopup];
}


- (void) abortInstallation {
    
    if (_installing) {
        
        [[DownloadManager instance] cancelDownload];
    }
}





#pragma mark - Existing Subscription

- (BOOL) _existingActiveSubscription {
    
    // dev
    
    if (!_subscriptionsEnabled) return YES;
    
    
    
    
    BOOL hasActiveSubscription = [[SubscriptionManager instance] hasActiveSubscription];
    
    return hasActiveSubscription;
}





#pragma mark - Installed Content


//- (BOOL) contentInstalledForLesson:(Lesson *)lesson {
//
//    Course* course = lesson.course;
//    
//    return [self contentInstalledForCourse:course];
//}
//
//

- (BOOL) _contentInstalledForCourse:(Course*) course {
    
    return [self _courseInstalledWithID:course.id];
}







#pragma mark Retrieve Resources

- (UIImage*) largeVocabularyImageNamed:(NSString*) imageName forLesson:(Lesson*) lesson {
    
    NSString* fileName = [imageName stringByDeletingPathExtension];
    fileName = [fileName stringByAppendingString:@"_large"];
    fileName = [fileName stringByAppendingPathExtension:@"jpg"];
    
    NSString* folderPath = [self _fullPathToFolderForLesson:lesson];
    folderPath = [folderPath stringByAppendingPathComponent:FOLDER_IMAGES_VOCABULARIES_LARGE];
    
    NSString* fullFilePath = [folderPath stringByAppendingPathComponent:fileName];
    
    UIImage* image = [UIImage imageWithContentsOfFile:fullFilePath];
    
    return image;
}


- (UIImage*) smallVocabularyImageNamed:(NSString*) imageName forLesson:(Lesson*) lesson {
    
    NSString* fileName = [imageName stringByDeletingPathExtension];
    fileName = [fileName stringByAppendingString:@"_small"];
    fileName = [fileName stringByAppendingPathExtension:@"jpg"];
    
    NSString* folderPath = [self _fullPathToFolderForLesson:lesson];
    folderPath = [folderPath stringByAppendingPathComponent:FOLDER_IMAGES_VOCABULARIES_SMALL];
    
    NSString* fullFilePath = [folderPath stringByAppendingPathComponent:fileName];
    
    UIImage* image = [UIImage imageWithContentsOfFile:fullFilePath];
    
    return image;
}


- (NSString*) vocabularyAudioPathForFileName:(NSString*) fileName forLesson:(Lesson*) lesson {

    NSString* fileName2 = [fileName stringByDeletingPathExtension];
    fileName2 = [fileName2 stringByAppendingPathExtension:@"mp3"];

    NSString* folderPath = [self _fullPathToFolderForLesson:lesson];
    folderPath = [folderPath stringByAppendingPathComponent:FOLDER_AUDIOS_VOCABULARIES];
    
    NSString* fullFilePath = [folderPath stringByAppendingPathComponent:fileName2];
    
    return fullFilePath;
}


- (NSString*) popupPathForFileName:(NSString*) fileName forLesson:(Lesson*) lesson {
    
    NSString* fileName2 = [fileName stringByDeletingPathExtension];
    fileName2 = [fileName2 stringByAppendingPathExtension:@"html"];
    
    NSString* folderPath = [self _fullPathToFolderForLesson:lesson];
    folderPath = [folderPath stringByAppendingPathComponent:FOLDER_POPUPS];
    
    NSString* fullFilePath = [folderPath stringByAppendingPathComponent:fileName2];
    
    return fullFilePath;
}


- (NSString*) dialogAudioPathForFileName:(NSString*) fileName forLesson:(Lesson*) lesson {
    
    NSString* fileName2 = [fileName stringByDeletingPathExtension];
    fileName2 = [fileName2 stringByAppendingPathExtension:@"mp3"];
    
    NSString* folderPath = [self _fullPathToFolderForLesson:lesson];
    folderPath = [folderPath stringByAppendingPathComponent:FOLDER_AUDIOS_DIALOG];
    
    NSString* fullFilePath = [folderPath stringByAppendingPathComponent:fileName2];
    
    return fullFilePath;
}



#pragma mark - Installed Content

- (BOOL) _courseInstalledWithID:(int32_t) courseID {
    
    NSString* IDString = [NSString stringWithFormat:@"%d", courseID];

    NSDictionary* coursesDict = [_settingsManager valueForKey:@"courses"];
    
    BOOL courseInstalled = [coursesDict[IDString] boolValue];
    
    return courseInstalled;
}


- (void) _setCourseInstalledWithID:(int32_t) courseID {
    
    NSString* IDString = [NSString stringWithFormat:@"%d", courseID];
    
    NSMutableDictionary* coursesDict = [[_settingsManager valueForKey:@"courses"] mutableCopy];
    
    if (!coursesDict) {
        
        coursesDict = [NSMutableDictionary dictionary];
    }

    [coursesDict setValue:@(YES) forKey:IDString];
    
    [_settingsManager setValue:coursesDict forKey:@"courses"];
}




#pragma mark - Popup

- (void) _showPopup {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    ContentManagerInstallPopupController* controller = [storyboard instantiateViewControllerWithIdentifier:@"Install Popup"];
    controller.courseTitle = _course.title;
    
    __weak UIViewController* weakController = _parentViewController;
    __weak ContentManager* weakSelf = self;
    
    
    controller.cancelCloseBlock = ^void() {
        
        [weakController dismissViewControllerAnimated:YES completion:^{
            
            
        }];
    };
    
    controller.cancelDownloadBlock = ^void() {
      
        [weakSelf _cancelDownload];
        
        [weakController dismissViewControllerAnimated:YES completion:^{
            
            
        }];
    };

    controller.confirmDownloadBlock = ^void() {
        
        [weakSelf _startInstalling];
    };

    controller.confirmDownloadCompleteBlock = ^void() {
      
        [weakController dismissViewControllerAnimated:YES completion:^{
            
            
        }];
    };
    
    
    [_parentViewController presentViewController:controller animated:YES completion:^{
        
        
    }];
}




#pragma mark - Manage Installation

- (void) _startInstalling {
    
    // download package and wait for callback when finished
    
    // put it in the settings manager (for future cleanup)
    
    _installing = YES;
    
    [self _downloadCourseContent];
}


- (void) _finishInstalling {
    
    // copy/unzip temporary download file to destination (?)
    // cleanup download file
    // populate user db

    _installing = NO;
    
    
    [self _unzipPackage];
    
    [self _setCourseInstalledWithID:_course.id];
    
    [self _cleanUp];
    
    [[ContentDataManager instance] reloadCourseStores];
    
    [[UserDataManager instance] populateForCourse:_course];
    
    [self _reportFinishedInstalling];
}


- (void) _abortInstalling {
    
    _installing = NO;
    
    [self _cleanUp];
}


- (void) _cleanUp {
    
    [[DownloadManager instance] cleanUp];
    
    [[DownloadManager instance] removeObserver:self];
}






#pragma mark - Manage Download

- (void) _downloadCourseContent {

    NSDictionary* courseDict = [self _contentDictionaryForCourse:_course];
    NSString* fileName = courseDict[@"downloadFile"];
    
    [[DownloadManager instance] addObserver:self];
    
    [[DownloadManager instance] downloadFileWithDictionary:@{
                                                            @"fileName" : fileName,
                                                            }];
}


- (void) _cancelDownload {
    
    NSLog(@"cancelling download");
    
    // what can be cancelled?
    // 1 download: yes --> cleanup: remove downloaded file
    // 2 unzip/copy: yes --> cleanup: remove copied files
    // 3 user db: maybe --> undo inserts?
    
    // or: only let cancel download, afterwards disabled cancel button?
    
    [[DownloadManager instance] cancelDownload];
    
//    [self _cleanUp];
    
    [self _abortInstalling];
}


- (void) cleanUpDownloads {
    
    [[DownloadManager instance] cleanUp];
}



#pragma mark - Unzip Package

- (void) _unzipPackage {

    NSDictionary* courseDict = [self _contentDictionaryForCourse:_course];
    NSString* courseDirectory = courseDict[@"folderName"];
    
    NSString* archivePath = [DownloadManager instance].temporaryDownloadFilePath;
    
    NSString* libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString* contentDataDirectory = [libraryDirectory stringByAppendingPathComponent:CONTENT_DATA_DIRECTORY];
    NSString* destinationPath = [contentDataDirectory stringByAppendingPathComponent:courseDirectory];
    
    NSError* error;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (error) {
        
        NSLog(@"Error: %@", [error description]);
    }
    
    
    // exclude course folder from backup
    
    [self _excludePathFromBackup:destinationPath];
    
    
//    NSError* error = nil;
    
    [SSZipArchive unzipFileAtPath:archivePath
                    toDestination:destinationPath
                        overwrite:YES
                         password:@"weawaLjQ5#?VA={':CHZR@>zycp<7BRYP,<A=m+AS*42Zhu=6T"
                            error:&error delegate:nil];
    
    if (error) {
        
        NSLog(@"Error: %@", [error description]);
        ;
    }
}


- (void) _excludePathFromBackup:(NSString*) path {
    
    NSURL* URL = [NSURL fileURLWithPath:path];
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSLog(@"Excluding URL from backup: %@", URL);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error: &error];
    
    if(!success){
        
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
}




#pragma mark - Observers

- (void) addObserver:(id<ContentManagerObserver>)observer {
    
    NSValue* value = [NSValue valueWithNonretainedObject:observer];
    
    if (![self.observers containsObject:value]) {
    
        [self.observers addObject:value];
    }
}


- (void) removeObserver:(id<ContentManagerObserver>)observer {
    
    [self.observers removeObject:[NSValue valueWithNonretainedObject:observer]];
}


- (void) _reportDownloadStarted {
    
    for (NSValue* value in self.observers) {
        
        id<ContentManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(contentManagerStartedDownloadingContentForLesson:)]) {
            
            [observer contentManagerStartedDownloadingContentForLesson:nil];
        }
    }
}


- (void) _reportUpdateProgress:(float) progress {
    
    for (NSValue* value in self.observers) {
        
        id<ContentManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(contentManagerUpdatedProgress:forDownloadingContentForLesson:)]) {
            
            [observer contentManagerUpdatedProgress:progress forDownloadingContentForLesson:nil];
        }
    }
}


- (void) _reportDownloadFinished {
    
    for (NSValue* value in self.observers) {
        
        id<ContentManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(contentManagerFinishedDownloadingContentForLesson:)]) {
            
            [observer contentManagerFinishedDownloadingContentForLesson:nil];
        }
    }
}


- (void) _reportFinishedInstalling {
    
    for (NSValue* value in self.observers) {
        
        id<ContentManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(contentManagerFinishedInstallingContentForLesson:)]) {
            
            [observer contentManagerFinishedInstallingContentForLesson:nil];
        }
    }
}


- (void) _reportDownloadAbortedWithError:(NSError*) error {
    
    for (NSValue* value in self.observers) {
        
        id<ContentManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(contentManagerAbortedInstallationWithError:)]) {
            
            [observer contentManagerAbortedInstallationWithError:error];
        }
    }
}





#pragma mark - DownloadManagerObserver {

- (void) downloadManagerStartedDownloading {
    
    [self _reportDownloadStarted];
}


- (void) downloadManagerUpdatedDownloadProgress:(float)progress {
    
    [self _reportUpdateProgress:progress];
}


- (void) downloadManagerFinishedDownloading {
    
    [self _reportDownloadFinished];
    
    [self _finishInstalling];
}


- (void) downloadManagerAbortedDownloadWithError:(NSError *)error {
    
    [self _reportDownloadAbortedWithError:error];
    
    [self _abortInstalling];
    
//    [self _showError:error];
}





//#pragma mark - Error Alert
//
//- (void) _showError:(NSError*) error {
//    
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Fehler" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    
//    [alertView show];
//}



#pragma mark - Utility

- (NSDictionary*) _contentDictionaryForCourse:(Course*) course {
    
    NSNumber* courseID = @(course.id);
    NSDictionary* contentDict = nil;
    
    for (NSDictionary* dict in _contentDict[@"courses"]) {
        
        if ([dict[@"id"] isEqual:courseID]) {
            
            contentDict = dict;
            break;
        }
    }
    
    return contentDict;
}


- (NSString*) _fullPathToFolderForLesson:(Lesson*) lesson {
    
    if (lesson.isTeaser) {
        
        return [[[NSBundle mainBundle] pathForResource:CONTENT_DATA_DIRECTORY ofType:nil] stringByAppendingPathComponent:TEASER_CONTENT_DIRECTORY];
    }
    else {
    
        NSDictionary* courseDict = [self _contentDictionaryForCourse:lesson.course];
        
        return [self _fullPathToCourseFolderWithName:courseDict[@"folderName"]];
    }
}


- (NSString*) _fullPathToCourseFolderWithName:(NSString*) folderName {
    
#ifdef CHECK_CONTENT_IN_BUNDLE

    NSString* bundlePath = [[NSBundle mainBundle] pathForResource:CONTENT_DATA_DIRECTORY ofType:nil];
    NSString* coursePath = [bundlePath stringByAppendingPathComponent:folderName];
    
    return coursePath;
    
#else
    
    NSString* libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString* contentDataDirectory = [libraryDirectory stringByAppendingPathComponent:CONTENT_DATA_DIRECTORY];
    NSString* destinationPath = [contentDataDirectory stringByAppendingPathComponent:folderName];
    
    return destinationPath;
    
#endif
}





#pragma mark - Check Content In Bundle (Testing)

- (void) _checkContentInBundle {

    [self _setCourseInstalledWithID:10];
    [self _setCourseInstalledWithID:20];
    [self _setCourseInstalledWithID:30];
    [self _setCourseInstalledWithID:40];
}



@end
