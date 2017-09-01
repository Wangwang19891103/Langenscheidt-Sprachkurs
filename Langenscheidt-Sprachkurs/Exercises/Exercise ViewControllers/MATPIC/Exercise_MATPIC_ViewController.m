//
//  Exercise_MATPIC_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Exercise_MATPIC_ViewController.h"
#import "ExerciseCorrectionView.h"
#import "UILabel+HTML.h"
#import "VocabularyFormatter.h"
#import "SettingsManager.h"


@implementation Exercise_MATPIC_ViewController

@synthesize matpicView;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.layoutMode = FullscreenWithoutAdjust;
    self.canBeChecked = NO;
    self.hidesBottomButtonInitially = NO;
    
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createView];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.exerciseNavigationController setBottomButtonHidden:YES animated:NO];
}


- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
}


- (void) createView {
    
    self.matpicView = [[MATPICView alloc] init];
    self.matpicView.delegate = self;
    self.matpicView.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    self.matpicView.fontName = @"HelveticaNeue";
    self.matpicView.fontSize = 14.0;
    self.matpicView.fontColor = [UIColor colorWithWhite:0.13 alpha:1.0];
    self.matpicView.imageWidth = 130.0;
    self.matpicView.labelSpacing = 5.0;
    self.matpicView.horizontalSpacing = 20.0;
    self.matpicView.verticalSpacing = 20.0;
    
    Exercise* exercise = self.exerciseDict[@"exerciseObject"];
//    Course* course = [[ContentDataManager instance] courseForExerciseCluster:exercise.cluster];
    Lesson* lesson = [[ContentDataManager instance] lessonForExerciseCluster:exercise.cluster];
    
    self.matpicView.lesson = lesson;
    
    [self.matpicContainerView addSubview:self.matpicView];
    
    [self.matpicContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[matpicView]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(matpicView)]];
    [self.matpicContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[matpicView]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(matpicView)]];
    
    self.matpicView.vocabularySets = [self _createVocabularySets];
    
    self.matpicView.roundDelay = 2.0;

    [self.matpicView createView];
}


- (NSString*) instruction {

    return @"Wähle das richtige Bild";
}



- (NSArray*) _createVocabularySets {
    
    NSMutableArray* sets = [NSMutableArray array];
    
    for (NSDictionary* lineDict in self.exerciseDict[@"lines"]) {
        
        NSInteger vocabularyID = [lineDict[@"field1"] integerValue];
        Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];

        NSMutableDictionary* set = [NSMutableDictionary dictionary];
        set[@"textLang1"] = vocabulary.textLang1;
        set[@"prefixLang1"] = vocabulary.prefixLang1;
        set[@"textLang2"] = vocabulary.textLang2;
        set[@"prefixLang2"] = vocabulary.prefixLang2;
        set[@"image"] = vocabulary.imageFile;
        
        [sets addObject:set];
    }
    
    return sets;
}


- (void) matpicView:(MATPICView *)matpicView didStartNewRoundWithVocabularySet:(NSDictionary *)vocabularySet {
    
//    NSString* textLang1 = [NSString stringWithFormat:@"%@%@", vocabularySet[@"prefixLang1"] ? [NSString stringWithFormat:@"%@ ", vocabularySet[@"prefixLang1"]] : @"", vocabularySet[@"textLang1"]];
    self.topLabel.text = [VocabularyFormatter formattedStringForLanguage:Lang1 withDictionary:vocabularySet];
    [self.topLabel parseHTML];
}


- (void) matpicViewDidFinishLastRound:(MATPICView *)matpicView {
    
    [self.exerciseNavigationController setBottomButtonHidden:NO animated:YES];
    
    [self _assignScore];
}



#pragma mark - Score

- (void) _assignScore {
    
    NSInteger score = self.matpicView.scoreAfterFinish;
    NSInteger maxScore = self.matpicView.maxScore;
    
    [self setScore:score ofMaxScore:maxScore];
}




#pragma mark - Stop

- (void) stop {
    
    [super stop];
    
}


@end
