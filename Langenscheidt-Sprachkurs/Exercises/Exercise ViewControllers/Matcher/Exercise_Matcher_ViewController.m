//
//  Exercise_LTXT_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Exercise_Matcher_ViewController.h"
#import "ExerciseCorrectionView.h"
#import "VocabularyFormatter.h"


@implementation Exercise_Matcher_ViewController

@synthesize matcherView;
@synthesize contentStackView;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    [self.contentStackView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //    [self.contentStackView addSubview:self.topTextView];
    
    
    [self createView];
    
}





- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
}


- (void) createView {
    
    self.matcherView = [[HorizontalMatcherView alloc] init];
    self.matcherView.layoutMargins = UIEdgeInsetsMake(0, 20, 0, 20);
    
    [self.contentStackView addSubview:self.matcherView];

    
    self.matcherView.pairs = [self _createPairs];
    
    [self.matcherView createView];
}


- (NSArray*) _createPairs {  //FIX
    
    ExerciseType type = [self.exerciseDict[@"type"] integerValue];
    
    if (type == RANDOM_VOC_MULTIPLE) {
        
        return [self _createPairsFromVocabularies];
    }
    else {
        
        return [self _createPairsFromExercise];
    }
}


- (NSArray*) _createPairsFromExercise {
    
    NSMutableArray* pairs = [NSMutableArray array];

    for (NSDictionary* lineDict in self.exerciseDict[@"lines"]) {
        
        NSString* field1 = lineDict[@"field1"];
        NSString* field2 = lineDict[@"field2"];
        
        if (!field1 || !field2) {
            
            //            [self setErrorWithDescription:@"Missing field1 and/or field2 in exercise."];
            //            return nil;
        }
        
        [pairs addObject:@[
                           field1,
                           field2
                           ]];
    }

    return pairs;
}


- (NSArray*) _createPairsFromVocabularies {
    
    NSMutableArray* pairs = [NSMutableArray array];

    for (NSDictionary* lineDict in self.exerciseDict[@"lines"]) {
        
//        NSString* field1 = [NSString stringWithFormat:@"%@%@", vocDict[@"prefixLang1"] ? [NSString stringWithFormat:@"%@ ", vocDict[@"prefixLang1"]] : @"", vocDict[@"textLang1"]];
//        NSString* field2 = [NSString stringWithFormat:@"%@%@", vocDict[@"prefixLang2"] ? [NSString stringWithFormat:@"%@ ", vocDict[@"prefixLang2"]] : @"", vocDict[@"textLang2"]];

        NSInteger vocabularyID = [lineDict[@"field1"] integerValue];
        Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];
        
        NSString* field1 = [VocabularyFormatter formattedStringForLanguage:Lang1 withVocabulary:vocabulary];
        NSString* field2 = [VocabularyFormatter formattedStringForLanguage:Lang2 withVocabulary:vocabulary];
        
        [pairs addObject:@[
                           field1,
                           field2
                           ]];
    }
    
    return pairs;
}


- (NSString*) instruction {

    if (FALSE) {
        
        return @"Finde die Übersetzungen";
    }
    else {
        
        return [super instruction];
    }
}


- (void) check {
    
    [super check];
    
    BOOL correct = [self.matcherView check];
    NSInteger score = [self.matcherView scoreAfterCheck];
    NSInteger maxScore = [self.matcherView maxScore];

    [self setScore:score ofMaxScore:maxScore];
    
    
    if (correct) {
        
        [self playCorrectSound];
        
        UIView* checkView = [[UINib nibWithNibName:@"ExerciseCheckView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil][0];
        
        [self.contentStackView addSubview:checkView];
        [self.contentStackView setNeedsUpdateConstraints];
    }
    else {
        
        [self playWrongSound];
        
        NSArray* strings = [self.matcherView correctionStrings];
        
        ExerciseCorrectionView* correctionView = [[ExerciseCorrectionView alloc] init];
        correctionView.strings = strings;
        correctionView.tabular = YES;
        correctionView.layoutMargins = UIEdgeInsetsMake(0, 20, 0, 20);

        [correctionView createView];
        
        [self.contentStackView addSubview:correctionView];
        [self.contentStackView setNeedsUpdateConstraints];
//        [self.contentStackView layoutIfNeeded];
        
//        self.contentStackView.highlight = YES;
    }
    
    
    [self scrollBottomToVisible];

}


#pragma mark - Stop

- (void) stop {
    
    [super stop];
    
    
}



@end
