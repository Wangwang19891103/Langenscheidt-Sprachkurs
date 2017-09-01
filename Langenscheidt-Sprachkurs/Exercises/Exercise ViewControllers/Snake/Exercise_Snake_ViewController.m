//
//  Exercise_LTXT_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Exercise_Snake_ViewController.h"
#import "NSString+Clean.h"
#import "ExerciseCorrectionView.h"
#import "VocabularyFormatter.h"
#import "UILabel+HTML.h"


@implementation Exercise_Snake_ViewController

@synthesize snakeView;
@synthesize contentStackView;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    [self createView];
    
}





- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
}


- (void) createView {

    NSLog(@"Snake");

    
    ExerciseType type = [self.exerciseDict[@"type"] integerValue];
    
    NSString* toptext = self.exerciseDict[@"topText"];
    
    if (toptext) {
        
        self.topTextLabel.text = self.exerciseDict[@"topText"];
        [self.topTextLabel parseHTML];
    }
    else if (type == RANDOM_VOC_SINGLE) {
        
        NSInteger vocabularyID = [self.exerciseDict[@"lines"][0][@"field1"] integerValue];
        Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];
        self.topTextLabel.text = [VocabularyFormatter formattedStringForLanguage:Lang2 withVocabulary:vocabulary];
        [self.topTextLabel parseHTML];
    }
    else {
        
        [self.topTextContainer removeFromSuperview];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[contentStackView]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(contentStackView)]];
    }
    
    
    
    
    NSString* snakeString = nil;
    NSString* prefixString = nil;
    
//    ExerciseType type = [self.exerciseDict[@"type"] integerValue];
    
    if (type == RANDOM_VOC_SINGLE) {

        NSInteger vocabularyID = [self.exerciseDict[@"lines"][0][@"field1"] integerValue];
        Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];

        snakeString = vocabulary.textLang1;
        prefixString = vocabulary.prefixLang1;
    }
    else {
        
        snakeString = self.exerciseDict[@"lines"][0][@"field1"];
        
        // find prefix in regular snake exercise (scripted)
        
        NSArray* comps = [snakeString componentsSeparatedByString:@" "];
        
        if (comps.count == 2) {
            
            char firstChar = [comps[0] characterAtIndex:0];
            char lastChar = [comps[0] characterAtIndex:[comps[0] length] - 1];
            
            if (firstChar == '<' && lastChar == '>') {
                
                prefixString = [comps[0] substringWithRange:NSMakeRange(1, [comps[0] length] - 2)];
                snakeString = comps[1];
            }
        }
    }

    NSAssert(snakeString, @"No snake string");

    self.snakeView = [[SnakeView alloc] init];
    self.snakeView.layoutMargins = UIEdgeInsetsMake(0, 20, 0, 20);
    self.snakeView.string = snakeString;
    self.snakeView.prefix = prefixString;
    
    [self.contentStackView addSubview:self.snakeView];
    
    
    [self.snakeView createView];
}


- (NSString*) instruction {
    
    ExerciseType type = [self.exerciseDict[@"type"] integerValue];

    if (type == RANDOM_VOC_SINGLE) {

        return @"Finde die Übersetzung";
    }
    else {
        
        return [super instruction];
    }
}


- (void) check {
    
    [super check];
    
    BOOL correct = [self.snakeView check];
    NSInteger score = self.snakeView.scoreAfterCheck;
    NSInteger maxScore = self.snakeView.maxScore;
    
    [self setScore:score ofMaxScore:maxScore];
    
    if (correct) {
        
        [self playCorrectSound];
    }
    else {
        
        [self playWrongSound];
    }

    
    if (correct) {
        
        UIView* checkView = [[UINib nibWithNibName:@"ExerciseCheckView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil][0];
        
        [self.contentStackView addSubview:checkView];
        [self.contentStackView setNeedsUpdateConstraints];
    }
    else {
        
        ExerciseCorrectionView* correctionView = [[ExerciseCorrectionView alloc] init];
        correctionView.layoutMargins = UIEdgeInsetsMake(0, 20, 0, 20);
        correctionView.strings = @[self.snakeView.string];
        
        [correctionView createView];
        
        [self.contentStackView addSubview:correctionView];
        [self.contentStackView setNeedsUpdateConstraints];
        //        [self.contentStackView layoutIfNeeded];
    }
    
    
    [self scrollBottomToVisible];

}




#pragma mark - Stop

- (void) stop {
    
    [super stop];
    
}


@end
