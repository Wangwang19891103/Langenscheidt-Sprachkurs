//
//  ExerciseViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExerciseViewController.h"
#import "ExerciseNavigationController.h"
#import "ContentDataManager.h"
#import "ExerciseDictionary.h"
#import "ExerciseTypes.h"
@import AVFoundation;




#define AUTOGENERATED_VOCABULARY_EXERCISE_CLUSTER_ID_RANGE          1000000


@implementation ExerciseViewController

@synthesize exerciseDict;
//@synthesize vocabularyDict;
@synthesize layoutMode;
@synthesize checked;
@synthesize exerciseNavigationController;



#pragma mark - Initilization


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    [self initialize];
    
    return self;
}


- (id) init {
    
    self = [super init];

    [self initialize];

    return self;
}


- (void) initialize {

    _canBeChecked = YES;
    _hidesBottomButtonInitially = NO;
    
}





#pragma mark - UIViewController

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self stopIfNeeded];
}



#pragma mark - Instruction


- (NSString*) instruction {
    
    if (self.exerciseDict) {
        
        return self.exerciseDict[@"instruction"];
    }
    else return @"--- no instruction ---";
}



#pragma mark - Creating Exercise ViewControllers


+ (ExerciseViewController*) viewControllerForExerciseDictionary:(NSDictionary*) exerciseDict {

    ExerciseType type = [exerciseDict[@"type"] integerValue];
    ExerciseViewController* controller = [ExerciseViewController viewControllerForExerciseType:type exerciseDict:exerciseDict];
//    controller.exerciseDict = exerciseDict;
    
    return controller;
}


+ (ExerciseViewController*) viewControllerForExerciseType:(ExerciseType) type exerciseDict:(NSDictionary*) exerciseDict {

    ExerciseViewController* controller = nil;
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"exercises" bundle:[NSBundle mainBundle]];

    switch (type) {
            
        case LTXT_STANDARD:
        case LTXT_STANDARD_TABULAR:
        case LTXT_CUSTOM:
        case LTXT_CUSTOM_TABULAR:
        case DND:
        case DND_TABULAR:
            controller = [storyboard instantiateViewControllerWithIdentifier:@"LTXT"];
            break;
            
        case MATCHER:
            controller = [storyboard instantiateViewControllerWithIdentifier:@"Matcher"];
            break;
            
        case SCR:
            controller = [storyboard instantiateViewControllerWithIdentifier:@"SCR"];
            break;
            
        case MCH:
            controller = [storyboard instantiateViewControllerWithIdentifier:@"MCH"];
            break;
            
        case SNAKE:
            controller = [storyboard instantiateViewControllerWithIdentifier:@"Snake"];
            break;
            
        case VOCABFLOW:
            controller = [storyboard instantiateViewControllerWithIdentifier:@"VocabFlow"];
            break;

        case MATPIC:
            controller = [storyboard instantiateViewControllerWithIdentifier:@"MATPIC"];
            break;
            
        case DIALOG:
            controller = [storyboard instantiateViewControllerWithIdentifier:@"Dialog"];
            break;

        case RANDOM_VOC_MULTIPLE:
            controller = [ExerciseViewController exerciseViewControllerForRandomMultipleVocabulariesWithDict:exerciseDict];
            break;

        case RANDOM_VOC_SINGLE:
            controller = [ExerciseViewController exerciseViewControllerForRandomSingleVocabularyWithDict:exerciseDict];
            break;

        default:
            controller = [storyboard instantiateViewControllerWithIdentifier:@"not implemented"];
            break;
    }

    controller.exerciseDict = exerciseDict;
    
    return controller;
}



#pragma mark - Auto generated exercises

//+ (NSArray*) autoGeneratedExerciseViewControllersForVocabularyPearl:(Pearl*) pearl {
//    
//    NSMutableArray* viewControllers = [NSMutableArray array];
//    
//    NSArray* vocabularies = [[ContentDataManager instance] vocabulariesForPearl:pearl];
//    
//    
//    // step 1: 1 MATPIC or Matcher for all vocabularies
//    {
//        ExerciseViewController* controller = [ExerciseViewController randomExerciseViewControllerForMultipleVocabularies:vocabularies];
//        [viewControllers addObject:controller];
//    }
//    
//    // step 2: 1 other exercise for each vocabulary
//    {
//        NSArray* controllers = [ExerciseViewController randomExerciseViewControllersForSingleVocabularies:vocabularies];
//        [viewControllers addObjectsFromArray:controllers];
//    }
//    
//    
//    // populate user DB with auto generated exercises in ProgressManager
//    
//    [[UserProgressManager instance] populateWithAutogeneratedExerciseWithClusterIDIfNeeded:AUTOGENERATED_VOCABULARY_EXERCISE_CLUSTER_ID_RANGE inPearl:pearl];
//    
//    for (Vocabulary* vocabulary in vocabularies) {
//        
//        int32_t exerciseClusterID = AUTOGENERATED_VOCABULARY_EXERCISE_CLUSTER_ID_RANGE + vocabulary.id;
//        [[UserProgressManager instance] populateWithAutogeneratedExerciseWithClusterIDIfNeeded:exerciseClusterID inPearl:pearl];
//    }
//    
//    // -
//    
//    
//    
//    return viewControllers;
//}

//+ (ExerciseViewController*) randomExerciseViewControllerForMultipleVocabularies:(NSArray*) vocabularies {
//    
//    BOOL eligableForMATPIC = [ExerciseViewController vocabulariesEligableForMATPIC:vocabularies];
//    
//    ExerciseType type;
//    
//    if (!eligableForMATPIC) {
//        
//        type = MATCHER;
//    }
//    else {
//        
//        int MATPICOrMatcher = arc4random() % 2;
//        
//        type = (MATPICOrMatcher == 1) ? MATPIC : MATCHER;
//    }
//    
////    type = MATPIC;
//    
//    ExerciseViewController* controller = nil;
//    
//    if (type == MATPIC) {
//        
//        controller = [ExerciseViewController viewControllerForExerciseType:MATPIC];
//    }
//    else {
//        
//        controller = [ExerciseViewController viewControllerForExerciseType:MATCHER];
//        
//    }
//
//    NSDictionary* vocabularyDict = [ExerciseDictionary dictionaryForVocabularies:vocabularies];
//    controller.vocabularyDict = vocabularyDict;
//
//    
//    return controller;
//}


+ (BOOL) vocabulariesEligableForMATPICInDict:(NSDictionary*) exerciseDict {
    
    BOOL eligable = YES;
    
    for (NSDictionary* lineDict in exerciseDict[@"lines"]) {

        NSInteger vocabularyID = [lineDict[@"field1"] integerValue];
        Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];

        if (!vocabulary.imageFile) {
            
            eligable = NO;
            break;
        }
    }
    
    return eligable;
}



#pragma mark - Random Vocabulary Exercises

+ (ExerciseViewController*) exerciseViewControllerForRandomMultipleVocabulariesWithDict:(NSDictionary*) exerciseDict {
    
    BOOL eligableForMATPIC = [ExerciseViewController vocabulariesEligableForMATPICInDict:exerciseDict];
    
    ExerciseType type;
    
    if (!eligableForMATPIC) {
        
        type = MATCHER;
    }
    else {
        
        int MATPICOrMatcher = arc4random() % 2;
        
        type = (MATPICOrMatcher == 1) ? MATPIC : MATCHER;
    }
    
    type = MATPIC;
    
    ExerciseViewController* controller = nil;
    
    if (type == MATPIC) {
        
        controller = [ExerciseViewController viewControllerForExerciseType:MATPIC exerciseDict:exerciseDict];
    }
    else {
        
        controller = [ExerciseViewController viewControllerForExerciseType:MATCHER exerciseDict:exerciseDict];
    }
    
    return controller;
}


+ (ExerciseViewController*) exerciseViewControllerForRandomSingleVocabularyWithDict:(NSDictionary*) exerciseDict {
    
    NSInteger vocabularyID = [exerciseDict[@"lines"][0][@"field1"] integerValue];
    Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];
    
    ExerciseViewControllerVocabularyClass class = [ExerciseViewController classForVocabulary:vocabulary];
    NSArray* eligableTypes = [ExerciseViewController eligableTypesForVocabularyClass:class];
    int roll = arc4random() % eligableTypes.count;
    ExerciseType type = [eligableTypes[roll] integerValue];
    
    ExerciseViewController* controller = [ExerciseViewController viewControllerForExerciseType:type exerciseDict:exerciseDict];
    
    NSAssert(controller, @"controller is nil");

    return controller;
}



//+ (NSArray*) randomExerciseViewControllersForSingleVocabularies:(NSArray*) vocabularies {
//    
//    NSMutableArray* controllers = [NSMutableArray array];
//    
//    for (Vocabulary* vocabulary in vocabularies) {
//        
//        ExerciseViewController* controller = [ExerciseViewController randomExerciseViewControllerForVocabulary:vocabulary];
//        
//        [controllers addObject:controller];
//    }
//    
//    return controllers;
//}

+ (ExerciseViewControllerVocabularyClass) classForVocabulary:(Vocabulary*) vocabulary {
    
    ExerciseViewControllerVocabularyClass class = Unknown;

    NSInteger numberOfWords = [ExerciseViewController numberOfWordsInVocabulary:vocabulary];
    
    if (numberOfWords == 1) {
        
        class = Word;
    }
    else if (numberOfWords == 2) {
        
        class = ShortSentence;
    }
    else if (numberOfWords >= 3) {
        
        class = LongSentence;
    }
    
    return class;
}


+ (NSInteger) numberOfWordsInVocabulary:(Vocabulary*) vocabulary {
    
    
    NSString* string = vocabulary.textLang1;
    
    NSScanner* scanner = [[NSScanner alloc] initWithString:string];
//    NSMutableCharacterSet* skipSet = [[NSMutableCharacterSet alloc] init];
//    [skipSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    [skipSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    NSMutableCharacterSet* scanSet = [[NSMutableCharacterSet alloc] init];
    [scanSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
    [scanSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
//    NSCharacterSet* scanSet = [NSCharacterSet alphanumericCharacterSet];
    NSInteger numberOfWords = 0;

    NSLog(@"numberOfWordsInVocabulary '%@'", string);

    while (![scanner isAtEnd]) {
        
        [scanner scanUpToCharactersFromSet:scanSet intoString:nil];
        
        NSString* string;
        [scanner scanCharactersFromSet:scanSet intoString:&string];
        
        if (string && string.length > 0) {

            NSLog(@"%@", string);
            
            ++numberOfWords;
        }
    }
    
    NSLog(@"count: %ld", numberOfWords);
    
    return numberOfWords;
}


+ (NSArray*) eligableTypesForVocabularyClass:(ExerciseViewControllerVocabularyClass) class {
    
    switch (class) {

        case Word:
            
            return @[
                     @(SNAKE),
                     @(LTXT_CUSTOM_TABULAR)
                     ];
            break;

        case ShortSentence:
            
            return @[
                     @(LTXT_CUSTOM_TABULAR)
                     ];
            break;

        case LongSentence:
            
            return @[
                     @(SCR),
                     @(LTXT_CUSTOM_TABULAR)
                     ];
            break;

        default:
            return nil;
            break;
    }
}


+ (int32_t) autogeneratedVocabularyExerciseClusterIDRange {
    
    return AUTOGENERATED_VOCABULARY_EXERCISE_CLUSTER_ID_RANGE;
}




#pragma mark - Keyboard

- (void) handleKeyboardDidChangeFrameVisible:(BOOL) visible {
    
}




#pragma mark - Start

- (void) start {
    
}


- (void) stop {
    
    NSLog(@"ExerciseViewController - stop");
    
    _stopped = YES;
}


- (void) stopIfNeeded {
    
    if (!_stopped) {
        
        [self stop];
    }
}





# pragma mark - Check

- (void) check {
    
    checked = YES;
}


- (void) playCorrectSound {

    // ALSO CHANGE IN MATPIC VIEW !!!!!!!!!!!!
    
    NSURL* soundsURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds"];
    NSURL* URL = [soundsURL URLByAppendingPathComponent:@"nano/Stockholm_Haptic.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)URL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}


- (void) playWrongSound {
    
    NSURL* soundsURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds"];
    NSURL* URL = [soundsURL URLByAppendingPathComponent:@"nano/StockholmFailure_Haptic.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)URL,&soundID);
    AudioServicesPlaySystemSound(soundID);
    
}



#pragma mark - User Progress

- (void) setScore:(NSInteger) score ofMaxScore:(NSInteger) maxScore {

    NSLog(@"Exercise settings score: %ld / %ld", score, maxScore);
    
    Exercise* theExercise = self.exerciseDict[@"exerciseObject"];

    
    [[UserProgressManager instance] setScore:score ofMaxScore:maxScore forExercise:theExercise];
}




#pragma mark - Show bottom button

- (void) showBottomButton {
    
    [self.exerciseNavigationController setBottomButtonHidden:NO animated:YES];
}




#pragma mark - Handle Next Button

- (BOOL) shouldHandleNextButton {
    
    return NO;
}


- (void) handleNextButton {
    
}




#pragma mark - Handle Content Tap

- (BOOL) shouldHandleContentTap {
    
    return NO;
}


- (void) handleContentTap {
    
}



#pragma mark - Scroll To Visible

- (void) scrollBottomToVisible {
    
    // force layout update before scroll to visible
    
    [self.exerciseNavigationController.scrollview setNeedsLayout];
    [self.exerciseNavigationController.scrollview layoutIfNeeded];
    
    
    UIScrollView* scrollView = self.exerciseNavigationController.scrollview;
    
    CGFloat contentHeight = scrollView.contentSize.height;
    CGFloat frameHeight = scrollView.bounds.size.height;
    CGFloat insetBottom = scrollView.contentInset.bottom;
    
    CGPoint bottomOffset = CGPointMake(0, contentHeight - frameHeight  + insetBottom);
    
    NSLog(@"contentHeight: %f", contentHeight);
    NSLog(@"frameHeight: %f", frameHeight);
    NSLog(@"insetBottom: %f", insetBottom);
    NSLog(@"bottomOffset: %f", bottomOffset.y);
    
    if (bottomOffset.y > 0) {
        
        NSLog(@"scrolling bottom to visible");
        
        [scrollView setContentOffset:bottomOffset animated:YES];
    }
}




#pragma mark - Dealloc 

- (void) dealloc {
    
    NSLog(@"ExerciseViewController - dealloc");
}




@end
