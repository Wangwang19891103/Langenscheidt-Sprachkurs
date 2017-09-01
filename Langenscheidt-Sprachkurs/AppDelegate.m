//
//  AppDelegate.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "AppDelegate.h"

#import "UserDataManager.h"
#import "SettingsManager.h"


#import "ExerciseViewController.h"
#import "ExerciseTypes.h"
#import "Exercise.h"
#import "ExerciseCluster.h"
#import "Pearl.h"
#import "Lesson.h"
#import "Course.h"

#import "ContentManager.h"


#import "DatabaseDumperHTML.h"

#import "UserSettingsManager.h"

#import "DataManager2.h"

#import "SubscriptionManager.h"



#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAILogger.h"


#import "LTracker.h"



#define TAB_BAR_TINT_COLOR      [UIColor colorWithRed:0/255.0 green:151/255.0 blue:189/255.0 alpha:1.0]
#define TAB_BAR_BAR_TINT_COLOR  [UIColor whiteColor]

#define TAB_BAR_ITEM_FONT_NORMAL       [UIFont fontWithName:@"HelveticaNeue" size:9.0f]
#define TAB_BAR_ITEM_FONT_SELECTED     [UIFont fontWithName:@"HelveticaNeue-Bold" size:9.0f]





#define DEV_SETTINGS  // also in more menu view controller to disable dev menu





@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

//    [[UserDataManager instance] populateForLanguage];
    
    
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance] setTintColor:TAB_BAR_TINT_COLOR];
    [[UITabBar appearance] setBarTintColor:TAB_BAR_BAR_TINT_COLOR];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSFontAttributeName : TAB_BAR_ITEM_FONT_NORMAL,
                                                        } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSFontAttributeName : TAB_BAR_ITEM_FONT_SELECTED
                                                        } forState:UIControlStateHighlighted];
    [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -5)];
    

    
    BOOL showOnboarding = ![[[SettingsManager instanceNamed:@"general"] valueForKey:@"notFirstRun"] boolValue];
    
    BOOL dev_showOnboarding = [[[SettingsManager instanceNamed:@"dev"] valueForKey:@"showOnboarding"] boolValue];

    

    [self _setDefaultDevSettings];

    [self _setupGoogleAnalytics];

    
//    [self _dumpDatabase];
    
    
    [self _cleanUpDownloads];
    
    
    [self.window makeKeyAndVisible];
    
    
    
    
    if (showOnboarding || dev_showOnboarding) {
    
        [self _showOnboarding];
    }
    
//    [self _test];
    
    
    [[SubscriptionManager instance] requestUpdateHasActiveSubscriptionForceValidation:YES];
    
    
    return YES;
}


- (void) _cleanUpDownloads {
    
    [[ContentManager instance] cleanUpDownloads];
}


- (void) _test {

//    NSArray* fonts = [UIFont familyNames];
    
//    NSInteger number = [ExerciseViewController numberOfWordsInVocabulary:nil];
    
    ExerciseType type = LTXT_CUSTOM;
    
//    DataManager* d = [DataManager instanceInBundleNamed:@"content"];

//    NSArray* e = [d fetchDataForEntityName:@"Exercise" withPredicate:[NSPredicate predicateWithFormat:@"type == %d AND (explanation != nil OR topText != nil)", ltxtsta] sortedBy:@"id", nil];

//    NSArray* e = [d fetchDataForEntityName:@"Exercise" withPredicate:[NSPredicate predicateWithFormat:@"popupFile != nil"] sortedBy:@"id", nil];
    
    
    DataManager2* dm = [ContentDataManager instance].dataManager;
    
    NSArray* e = [dm fetchDataForEntityName:@"Exercise" withPredicate:[NSPredicate predicateWithFormat:@"audioFile != nil", type] sortedBy:@"id", nil];
    
    for (Exercise* ex in e) {
        
        Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:ex.cluster];
        
        NSLog(@"course: %@ --- lesson: %@ --- pearl: %@ --- cluster id: %d --- ex id: %d --- type: %@",
              pearl.lesson.course.title,
              pearl.lesson.title,
              pearl.title,
              ex.cluster.id,
              ex.id,
              [ExerciseTypes stringForExerciseType:ex.type]);
    }
    
    
}



- (void) _dumpDatabase {
    
    [[DatabaseDumperHTML instance] dump];
    ;
    ;
    
}



- (void) _showOnboarding {

    [self.window.rootViewController performSegueWithIdentifier:@"Onboarding" sender:self];
}


- (void) _setDefaultDevSettings {

    BOOL firstRun = ![[[SettingsManager instanceNamed:@"general"] valueForKey:@"notFirstRun"] boolValue];
    
    if (firstRun) {
     
        [[SettingsManager instanceNamed:@"general"] setValue:@(YES) forKey:@"notFirstRun"];
        [[SettingsManager instanceNamed:@"general"] setValue:@(YES) forKey:@"analyticsActivated"];
        
        
#ifdef DEV_SETTINGS
        
        [[SettingsManager instanceNamed:@"dev"] setValue:@(NO) forKey:@"skipToScoreScreen"];
        [[SettingsManager instanceNamed:@"dev"] setValue:@(NO) forKey:@"showOnboarding"];
        [[SettingsManager instanceNamed:@"dev"] setValue:@(YES) forKey:@"subscriptionsEnabled"];
        [[SettingsManager instanceNamed:@"dev"] setValue:@(NO) forKey:@"simulateError"];
        
#endif
        
        // populate structure
        
        [[UserDataManager instance] populateStructureAndTeaserContent];

    }
}







#pragma mark - Google Analytics

- (void) _setupGoogleAnalytics {
    
    // Configure tracker from GoogleService-Info.plist.
    
    NSString* trackingID = @"UA-33324403-21";
    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:trackingID];
    
    [[LTracker instance] setTracker:tracker];
    
    
    // Optional: configure GAI options.

    GAI *gai = [GAI sharedInstance];

//    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
//    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
//    gai.dryRun = YES;

    gai.dispatchInterval = 1;

    
    BOOL activated = [[[SettingsManager instanceNamed:@"general"] valueForKey:@"analyticsActivated"] boolValue];
    
    NSLog(@"setting GA opt-out to: %d", !activated);
    
    [[GAI sharedInstance] setOptOut:!activated];
    
    
//    [[[GAI sharedInstance] defaultTracker] set:kGAIScreenName value:@"AppStart"];
//    
//    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createScreenView] build]];
}






- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"App will enter foreground");
    
    [[SubscriptionManager instance] requestUpdateHasActiveSubscriptionForceValidation:NO];  // do not force here to avoid a viewcontroller that handles validation errors to have error popups surprisingly for the user when he enters foreground
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
