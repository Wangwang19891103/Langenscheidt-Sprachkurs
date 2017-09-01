//
//  UserProgressManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "UserProgressManager.h"
#import "SettingsManager.h"
#import "ContentManager.h"
#import "CustomAlertViewController.h"
#import "UserProgressManagerResetDataPopupView.h"




/*
 * ? transparency of exercises vs clusters in app? does user know that exercises belong to a cluster which must be all completed in order to get points?
 * ! upon continuing in pearl: start at first exercise of next unfinished cluster (in case user stopped in the middle of a cluster, its this cluster thats being restarted)
 *
 */

// auto-generated exercises are added when the vocabulary vocab flow exercise is first opened



#define DEVELOPER_ALERTS_ACTIVE         YES




@implementation UserProgressManager


- (id) init {
    
    self = [super init];
    
    _contentDataManager = [ContentDataManager instance];
    _userDataManager = [UserDataManager instance];
    
//    [self _populateUserDBIfNeeded];
    
    return self;
}


+ (id) instance {
    
    static UserProgressManager* __instance = nil;
    
    @synchronized(self) {
        
        if (!__instance) {
            
            __instance = [[UserProgressManager alloc] init];
        }
    }
    
    return __instance;
}



//#pragma mark - Populate If Needed
//
//- (void) _populateUserDBIfNeeded {
//    
//    BOOL populated = [[[SettingsManager instanceNamed:@"dev"] valueForKey:@"populated"] boolValue];
//    
//    if (YES || !populated) {
//
//        UIViewController* controller = [[UIViewController alloc] init];
//        controller.view.backgroundColor = [UIColor blackColor];
//        
//        UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        [activityView startAnimating];
//        
//        [controller.view addSubview:activityView];
//        
//        [controller.view addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:activityView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
//
//         [controller.view addConstraint:[NSLayoutConstraint constraintWithItem:controller.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:activityView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
//
//          
//        __weak UIWindow* window = [[UIApplication sharedApplication].delegate window];
//        [window.rootViewController presentViewController:controller animated:YES completion:^{
//            
//            [_userDataManager populateForLanguage];
//            
//            [window.rootViewController dismissViewControllerAnimated:YES completion:^{
//                
//                [[SettingsManager instanceNamed:@"dev"] setValue:@(YES) forKey:@"populated"];
//            }];
//        }];
//        
//        
//    }
//}




#pragma mark - Reset User Data

- (void) resetUserDataWithParentViewController:(UIViewController*) parentController {
    
    NSLog(@"reset user data");
    
    [self _showResetDataPopupParentViewController:parentController];
}


- (void) _showResetDataPopupParentViewController:(UIViewController*) parentController {
    
    CustomAlertViewController* controller = [[CustomAlertViewController alloc] init];
    
    UserProgressManagerResetDataPopupView* contentView = [[UserProgressManagerResetDataPopupView alloc] init];
    
    __weak UIViewController* weakController = parentController;
    
    contentView.confirmBlock = ^(void) {
        
        [[UserDataManager instance] reset];
        
        [weakController dismissViewControllerAnimated:YES completion:^{
            
            
        }];
    };
    
    contentView.cancelBlock = ^(void) {
        
        [weakController dismissViewControllerAnimated:YES completion:^{
            
            
        }];
    };
    
    
    controller.contentViews = @[contentView];
    
    [parentController presentViewController:controller animated:YES completion:^{
        
        
    }];
}





#pragma mark - Progress

- (float) progressForPearl:(Pearl*) pearl {
    
    NSInteger numberOfSolvedClusters = [self numberOfSolvedExerciseClustersForPearl:pearl];
    NSInteger numberOfAvailableClusters = [[UserDataManager instance] numberOfAvailableExerciseClustersForPearl:pearl];
    
    if (numberOfAvailableClusters == 0) {
    
        return 0;
    }
    else {
    
        float percentage = numberOfSolvedClusters / (float) numberOfAvailableClusters;
        
        return percentage;
    }
}



#pragma mark - ExerciseClusters / Exercises / Score

//- (void) setActiveExerciseClusterIfNewWithID:(int32_t) clusterID forPearl:(Pearl*) pearl {
//    
//    UserExerciseCluster* userExerciseCluster = [_userDataManager exerciseClusterWithID:clusterID forPearl:pearl];
//    
//    self setActiveExerciseClusterIfNew:<#(ExerciseCluster *)#>
//}


- (NSInteger) scoreForLanguage {

    return [_userDataManager scoreForLanguage];
}


- (NSInteger) scoreForCourse:(Course *)course {
    
    return [_userDataManager scoreForCourse:course];
}


- (NSInteger) scoreForLesson:(Lesson *)lesson {
    
    return [_userDataManager scoreForLesson:lesson];
}


- (NSInteger) scoreForPearl:(Pearl *)pearl {
    
    return [_userDataManager scoreForPearl:pearl];
}


- (void) setActiveExerciseClusterIfNew:(ExerciseCluster *)exerciseCluster {

    if ([self isNewExerciseCluster:exerciseCluster]) {
        
        [self setNewActiveExerciseCluster:exerciseCluster];
    }
}


- (BOOL) isNewExerciseCluster:(ExerciseCluster*) exerciseCluster {
    
    return exerciseCluster != _activeExerciseCluster;
}


- (void) setNewActiveExerciseCluster:(ExerciseCluster*) exerciseCluster {
    
    _activeExerciseCluster = exerciseCluster;
    _activeExerciseClusterDict = [NSMutableDictionary dictionary];
    
    for (Exercise* exercise in exerciseCluster.exercises) {
        
        [_activeExerciseClusterDict setObject:[NSNull null] forKey:@(exercise.id)];
    }
}


- (void) setScore:(NSInteger) score ofMaxScore:(NSInteger)maxScore forExercise:(Exercise *)exercise {
    
    NSAssert(_activeExerciseCluster && _activeExerciseClusterDict, @"");
    
    if (!_activeExerciseCluster || !_activeExerciseClusterDict) {
        
//        _alert(@"setScore: no active cluster set and/or no dict (l: %ld, p: %ld, c: %ld, e: %ld)",
//               exercise.cluster.pearl.lesson.id,
//               exercise.cluster.pearl.id,
//               exercise.cluster.id,
//               exercise.id);
    }

    id object = _activeExerciseClusterDict[@(exercise.id)];
    
//    NSNumber* scoreNumber = _activeExerciseClusterDict[@(exercise.id)];
    
    NSAssert([object isKindOfClass:[NSNull class]], @"");

//    if (![object isKindOfClass:[NSNull class]]) {
//        
//        _alert(@"setScore: score in dict not NULL before setting new score (l: %ld, p: %ld, c: %ld, e: %ld)",
//               exercise.cluster.pearl.lesson.id,
//               exercise.cluster.pearl.id,
//               exercise.cluster.id,
//               exercise.id);
//    }
    
    _activeExerciseClusterDict[@(exercise.id)] = @{
                                                   @"score" : @(score),
                                                   @"maxScore" : @(maxScore)
                                                   };
    
    
    [self _saveScoreForActiveExerciseClusterIfReady];
}


- (void) finalScoreForActivePearlScore:(NSInteger*) score maxScore:(NSInteger*) maxScore {
    
    Pearl* activePearl = [[ContentDataManager instance] pearlForExerciseCluster:_activeExerciseCluster];
    NSArray* events = [_userDataManager userExerciseClusterEventsForCurrentRunForPearl:activePearl latest:YES];
    NSInteger theScore = 0;
    NSInteger theMaxScore = 0;
    
    // check for consistency
    
    NSInteger numberOfAvailableExerciseClustersInPearl = [_userDataManager numberOfAvailableExerciseClustersForPearl:activePearl];
    NSInteger numberOfEvents = events.count;
    
//    // check 1: number compare
//    
//    if (numberOfEvents != numberOfAvailableExerciseClustersInPearl) {
//        
//        _alert(@"mismatching number for events and available clusters (%d, %d) (l: %ld, p: %ld)",
//               numberOfEvents,
//               numberOfAvailableExerciseClustersInPearl,
//               activePearl.lesson.id,
//               activePearl.id
//               );
//    }
    
    
    // check 2: every cluster present?
    
    NSArray* clusters = [_contentDataManager exerciseClustersForPearl:activePearl];
    BOOL allGood = YES;
    
    for (ExerciseCluster* cluster in clusters) {
        
        BOOL found = NO;
        
        for (UserExerciseClusterEvent* event in events) {
            
            if (event.cluster.id == cluster.id) {
    
                theScore += event.score;
                theMaxScore += event.maxScore;
                
                found = YES;
                break;
            }
        }
        
        if (!found) {
            
            allGood = NO;
            break;
        }
    }
    
    if (!allGood) {
        
//        _alert(@"not all clusters represented in events (%d, %d) (l: %ld, p: %ld)",
//               numberOfEvents,
//               numberOfAvailableExerciseClustersInPearl,
//               activePearl.lesson.id,
//               activePearl.id
//               );
    }
    
    *score = theScore;
    *maxScore = theMaxScore;
    
    // -
}




#pragma mark - Next Pearl

- (Pearl*) nextPearlForPearl:(Pearl*) pearl {
    
    return [[ContentDataManager instance] nextPearlForPearl:pearl];
}


//#pragma mark - Populate auto-generated exercises
//
//- (void) populateWithAutogeneratedExerciseWithClusterIDIfNeeded:(int32_t) exerciseClusterID inPearl:(Pearl*) pearl {
//    
//    [_userDataManager populateWithAutogeneratedExerciseWithClusterIDIfNeeded:(int32_t) exerciseClusterID inPearl:(Pearl*) pearl];
//}





#pragma mark - Your Lesson (Deine Lektion)

- (Lesson*) currentUserLesson {
    
    // the current user lesson is:
    // - the lesson the user was last active in
    // - i.e.
    // - 1. has completed an exercise/pearl in
    // - 2. has navigated to manually (menus)
    // - in case of completing the last pearl in a lesson -> it is the - nextPearlForPearl
    
    // 1. in LessonViewController ???????
    // 2. in ExerciseNavigationController - when starting exercises for a pearl
    // 3. in ExerciseNavigationController - when completing the last exercise (at score screen)
    
    Lesson* currentUserLesson = [_userDataManager currentUserLesson];
    
    return currentUserLesson;
}


- (void) setCurrentUserLesson:(Lesson *)lesson {
    
    [_userDataManager setCurrentUserLesson:lesson];
}




#pragma mark - Completion Status for Lesson / Course

- (UserProgressLessonCompletionStatus) completionStatusForLesson:(Lesson*) lesson {
    
    NSInteger availablePearls = [[_contentDataManager pearlsForLesson:lesson] count];
    NSInteger solvedPearls = [self numberOfSolvedPearlsForLesson:lesson];
    BOOL isLessonNew = [_userDataManager isLessonNewForCurrentRun:lesson];
    
    UserProgressLessonCompletionStatus completionStatus;
    
    if (isLessonNew) {  // this needs to be changed and also checked for started pearls
        
        completionStatus = UserProgressLessonCompletionStatusNew;
    }
    else if (solvedPearls < availablePearls) {
        
        completionStatus = UserProgressLessonCompletionStatusStarted;
    }
    else if (solvedPearls == availablePearls) {
        
        completionStatus = UserProgressLessonCompletionStatusCompleted;
    }
    
    
    return completionStatus;
}


- (UserProgressLessonCompletionStatus) completionStatusForCourse:(Course*) course {
    
    NSInteger availableLessons = [[_contentDataManager lessonsForCourse:course] count];
    NSInteger solvedLessons = [self numberOfSolvedLessonsForCourse:course];
    BOOL isCourseNew = [_userDataManager isCourseNewForCurrentRun:course];
    
    UserProgressLessonCompletionStatus completionStatus;
    
    if (isCourseNew) {  // this needs to be changed and also checked for started pearls
        
        completionStatus = UserProgressLessonCompletionStatusNew;
    }
    else if (solvedLessons < availableLessons) {
        
        completionStatus = UserProgressLessonCompletionStatusStarted;
    }
    else if (solvedLessons == availableLessons) {
        
        completionStatus = UserProgressLessonCompletionStatusCompleted;
    }
    
    
    return completionStatus;
}




#pragma mark - Next incomplete pearl / exercise cluster in lesson

//- (Pearl*) nextIncompletePearlForLesson:(Lesson*) lesson {  // used for the "continue lesson" button
//    
//    ExerciseCluster* nextIncompleteCluster = [self nextIncompleteExerciseClusterForLesson:lesson];
//    
//    return nextIncompleteCluster.pearl;
//}


- (ExerciseCluster*) nextIncompleteExerciseClusterForLesson222:(Lesson*) lesson {  // can return nil (but shud never be forced to)
    
    // this method is made to be called in PearlViewController to start/continue a lesson
    // searching for the next pearl will cycle back to the start
    
    ExerciseCluster* nextCluster = nil;

    
    // 1. determine last active exercise cluster in lesson (use cluster events) (the cluster has been completed, run = lessonRun)
    
    ExerciseCluster* lastActiveExerciseCluster = [_userDataManager mostRecentExerciseClusterForUserLessonForCurrentRun:lesson];  // can be nil
    
    
    // 2. find next incomplete exercise cluster in lesson
    
    if (!lastActiveExerciseCluster) {
        
        nextCluster = [[ContentDataManager instance] firstClusterForLesson:lesson];
    }
    else {

        ExerciseCluster* currentCluster = lastActiveExerciseCluster;

        do {
            
            // iterate to next cluster within lesson
            
            currentCluster = [_contentDataManager nextExerciseClusterForExerciseCluster:currentCluster inSameLesson:YES];
            
            
//            // if a new lesson has been skipped to -> return the cluster regardless of completion status (dont compare runs)
//            
//            if (currentCluster.pearl.lesson.id != lesson.id) {  // is different lesson
//            
//                nextCluster = currentCluster;
//                break;
//            }

            // else compare UserExerciseCluster run to lesson run. if it is lower than lesson run -> next cluster is found

//            else {
            
            
            Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:currentCluster];
            NSInteger lessonRun = [_userDataManager runForLesson:pearl.lesson];
            NSInteger clusterRun = [_userDataManager runForExerciseCluster:currentCluster];
            
            if (clusterRun < lessonRun) {
                
                nextCluster = currentCluster;
                break;
            }
//            }
            
        } while (currentCluster != lastActiveExerciseCluster);  // do max one full circle back to starting cluster then break (which will probably not happen, depends on current implementation, this is just for safety)
        
    }
    
    
    return nextCluster;
}


- (ExerciseCluster*) nextIncompleteExerciseClusterForPearlInsideSamePearl:(Pearl*) pearl {  // will only look inside same pearl
    
    ExerciseCluster* nextCluster = nil;
    
    
    // 1. determine last active exercise cluster in pearl (use cluster events) (the cluster has been completed, run = lessonRun)
    
    ExerciseCluster* lastActiveExerciseCluster = [_userDataManager mostRecentExerciseClusterForPearlForCurrentRun:pearl];  // can be nil
    
    
    // 2. find next incomplete exercise cluster in lesson
    
    if (!lastActiveExerciseCluster) {
        
        nextCluster = [[ContentDataManager instance] firstClusterForPearl:pearl];
    }
    else {
        
        ExerciseCluster* currentCluster = lastActiveExerciseCluster;
        
        do {
            
            // iterate to next cluster within pearl
            
            currentCluster = [_contentDataManager nextExerciseClusterForExerciseCluster:currentCluster inSameLesson:YES];
            Pearl* nextPearl = [[ContentDataManager instance] pearlForExerciseCluster:currentCluster];
            
            // if a new pearl has been skipped to -> return nil
            
            if (nextPearl.id != pearl.id) {  // is different pearl
                
                nextCluster = [[ContentDataManager instance] firstClusterForPearl:pearl];  // will return first clusterl in the case that no incomplete cluster has been found, BUT the pearl will not be reset, i.e. no run increased
                break;
            }
            
            // else compare UserExerciseCluster run to lesson run. if it is lower than lesson run -> next cluster is found
            
            else {
                
                
                Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:currentCluster];
                NSInteger lessonRun = [_userDataManager runForLesson:pearl.lesson];
                NSInteger clusterRun = [_userDataManager runForExerciseCluster:currentCluster];
                
                if (clusterRun < lessonRun) {
                    
                    nextCluster = currentCluster;
                    break;
                }
            }
            
        } while (currentCluster != lastActiveExerciseCluster);  // do max one full circle back to starting cluster then break (which will probably not happen, depends on current implementation, this is just for safety)
        
    }
    
    
    return nextCluster;
}



//- (ExerciseCluster*) _nextExerciseClusterForExerciseCluster:(ExerciseCluster*) exerciseCluster {
//    
//    ExerciseCluster* nextCluster = nil;
//
//    
//    
//    return nextCluster;
//}




#pragma mark - Start next run for lesson

- (void) startNextRunForLesson:(Lesson*) lesson {
    
    [_userDataManager increaseRunForLesson:lesson];
}







#pragma mark - Other

- (NSInteger) numberOfExercisesBeforeExerciseCluster:(ExerciseCluster*) exerciseCluster {  // used for calculating total number of positions on exercise navigation progress bar
    
    Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:exerciseCluster];
    NSArray* exercises = [[ContentDataManager instance] exercisesForPearl:pearl];  // get siblings
    NSInteger numberOfSkippedExercises = 0;
    
    
    // iterate siblings and find cluster
    
    for (Exercise* exercise in exercises) {
        
        if (exercise.cluster.id == exerciseCluster.id) {  // found -> break
            
            break;
        }
        else {
            
            ++numberOfSkippedExercises;
        }
    }
    
    return numberOfSkippedExercises;
}


- (NSInteger) numberOfSolvedLessonsForCourse:(Course*) course {
 
//    BOOL contentInstalled = [[ContentManager instance] contentInstalledForCourse:course];
//    
//    if (!contentInstalled) {
//        
//        return 0;
//    }
//    else {
    
        return [_userDataManager numberOfSolvedLessonsForCourse:course];
//    }
}


//- (NSInteger) numberOfsolvedExerciseClustersForLesson:(Lesson*) lesson { // ?????????????????????
// 
//    return [_userDataManager numberOfSolvedPearlsForLesson:lesson];
//}


- (NSInteger) numberOfSolvedPearlsForLesson:(Lesson *)lesson {

    BOOL contentInstalled = [[ContentManager instance] contentInstalledForLesson:lesson];
    
    if (!contentInstalled) {
        
        return 0;
    }
    else {
        
        return [_userDataManager numberOfSolvedPearlsForLesson:lesson];
    }

}


- (NSInteger) numberOfSolvedExerciseClustersForPearl:(Pearl*) pearl {
    
    BOOL contentInstalled = [[ContentManager instance] contentInstalledForLesson:pearl.lesson];
    
    if (!contentInstalled) {
        
        return 0;
    }
    else {
        
        return [_userDataManager numberOfSolvedExerciseClustersForPearl:pearl];
    }
}



#pragma mark - Private


- (void) _saveScoreForActiveExerciseClusterIfReady {
    
    NSInteger totalScore = 0;
    NSInteger totalMaxScore = 0;
    BOOL ready = YES;
    
    for (NSNumber* idNumber in _activeExerciseClusterDict.allKeys) {
        
        id object = _activeExerciseClusterDict[idNumber];
        
        if ([object isKindOfClass:[NSNull class]]) {

            
            ready = NO;
            break;
        }
        else {

            NSDictionary* dict = _activeExerciseClusterDict[idNumber];
            NSInteger score = [dict[@"score"] integerValue];
            NSInteger maxScore = [dict[@"maxScore"] integerValue];

            totalScore += score;
            totalMaxScore += maxScore;
        }
    }
    
    if (ready) {
        
        [self _saveScoreForActiveExerciseCluster:totalScore ofMaxScore:totalMaxScore];
    }
}


- (void) _saveScoreForActiveExerciseCluster:(NSInteger) score ofMaxScore:(NSInteger) maxScore {
    
    [_userDataManager increaseScore:score forExerciseCluster:_activeExerciseCluster];
    [_userDataManager addExerciseClusterEventWithScore:score maxScore:maxScore forExerciseCluster:_activeExerciseCluster];
//    _activeExerciseCluster = nil;
//    _activeExerciseClusterDict = nil;
    
//    _alert(@"score for cluster: %d (max: %d)", score, maxScore);
}




#pragma mark - Developer Alerts

void _alert(NSString* text, ...) {
    
    if (!DEVELOPER_ALERTS_ACTIVE) return;
    
    va_list args;
    va_start(args, text);
    
    [[[UIAlertView alloc] initWithTitle:@"Development alert (bitte Screenshot machen)" message:[[NSString alloc] initWithFormat:text arguments:args] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

@end











