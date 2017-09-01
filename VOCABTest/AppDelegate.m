//
//  AppDelegate.m
//  VOCABTest
//
//  Created by Stefan Ueter on 08.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "AppDelegate.h"
#import "ExerciseNavigationController.h"
#import "ContentDataManager.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    ExerciseNavigationController* controller = [[UIStoryboard storyboardWithName:@"exercises" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Navigation Controller"];
    
    NSArray* courses = [[ContentDataManager instance] courses];
    NSArray* lessons = [[ContentDataManager instance] lessonsForCourse:courses[0] withType:VOCABFLOW];
    NSArray* pearls = [[ContentDataManager instance] pearlsForLesson:lessons[0] withType:VOCABFLOW];
    NSArray* exercises = [[ContentDataManager instance] exercisesForPearl:pearls[0] withType:VOCABFLOW];
    
    controller.exercise = exercises[0];
    
    [self.window setRootViewController:controller];
    
    return YES;
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
