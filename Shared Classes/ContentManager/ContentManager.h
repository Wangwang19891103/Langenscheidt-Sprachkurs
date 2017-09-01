//
//  ContentManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 12.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentDataManager.h"
#import "DownloadManager.h"
#import "SettingsManager.h"
@import UIKit;


@protocol ContentManagerObserver;



typedef NS_ENUM(NSInteger, ContentManagerContentAvailabilityStatus) {
    ContentManagerContentAvailabilityStatusAvailable,
    ContentManagerContentAvailabilityStatusNoSubscription,
    ContentManagerContentAvailabilityStatusNotInstalled
};



@interface ContentManager : NSObject <DownloadManagerObserver> {

    SettingsManager* _settingsManager;
    
    NSDictionary* _contentDict;
    
    UIViewController* _parentViewController;
    
    Course* _course;
    
    
    // dev
    
    BOOL _subscriptionsEnabled;
}

@property (nonatomic, strong) NSMutableArray* observers;

@property (nonatomic, readonly) BOOL installing;


+ (instancetype) instance;



#pragma mark - Public Methods

#pragma mark Available Content

- (ContentManagerContentAvailabilityStatus) contentAvailabilityStatusForLesson:(Lesson*) lesson;

//- (ContentManagerContentAvailabilityStatus) contentAvailabilityStatusForLesson:(Lesson*) lesson;

//- (BOOL) contentInstalledForCourse:(Course*) course;

- (BOOL) contentInstalledForLesson:(Lesson*) lesson;


#pragma mark Subscription

- (void) openShopPopupWithParentViewController:(UIViewController*) parentViewController;


#pragma mark Available Content Stores

- (NSArray*) availableCourseStorePaths;



#pragma mark Install new content

- (void) installContentForLesson:(Lesson*) lesson parentViewController:(UIViewController*) parentViewController;

- (void) cleanUpDownloads;

- (void) abortInstallation;



#pragma mark Observers

- (void) addObserver:(id<ContentManagerObserver>) observer;

- (void) removeObserver:(id<ContentManagerObserver>) observer;




- (UIImage*) largeVocabularyImageNamed:(NSString*) imageName forLesson:(Lesson*) lesson;

- (UIImage*) smallVocabularyImageNamed:(NSString*) imageName forLesson:(Lesson*) lesson;

- (NSString*) vocabularyAudioPathForFileName:(NSString*) fileName forLesson:(Lesson*) lesson;

- (NSString*) popupPathForFileName:(NSString*) fileName forLesson:(Lesson*) lesson;

- (NSString*) dialogAudioPathForFileName:(NSString*) fileName forLesson:(Lesson*) lesson;


@end




@protocol ContentManagerObserver <NSObject>

- (void) contentManagerStartedDownloadingContentForLesson:(Lesson*) lesson;

- (void) contentManagerUpdatedProgress:(float) progress forDownloadingContentForLesson:(Lesson*) lesson;

- (void) contentManagerFinishedDownloadingContentForLesson:(Lesson*) lesson;

- (void) contentManagerFinishedInstallingContentForLesson:(Lesson*) lesson;

- (void) contentManagerAbortedInstallationWithError:(NSError*) error;

@end