//
//  Exercise_LTXT_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Exercise_SCR_ViewController.h"
#import "ExerciseCorrectionView.h"
#import "VocabularyFormatter.h"
#import "UILabel+HTML.h"


#define FONT_NAME            @"HelveticaNeue"  // gets overridden in SCRLabel
#define FONT_SIZE           14  // overridden too
#define FONT_COLOR          [UIColor whiteColor];  // overridden too
#define HORIZONTAL_SPACING      4
#define VERTICAL_SPACING        4
#define BUTTON_MARGINS          25  // overridden too
#define FIXED_LABEL_BACKGROUND_COLOR    [UIColor colorWithWhite:0.8 alpha:1.0]
#define MOVABLE_LABEL_BACKGROUND_COLOR  [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]
#define GHOST_LABEL_BACKGROUND_COLOR [UIColor colorWithRed:190/255.0 green:227/255.0 blue:238/255.0 alpha:1.0]




@implementation Exercise_SCR_ViewController

@synthesize scrView;
@synthesize contentStackView;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    [self createView];
    
}





- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
}


- (void) createView {
    
    NSLog(@"SCR");
    
    
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

    
    
    
    
    self.scrView = [[SCRView alloc] init];
    self.scrView.layoutMargins = UIEdgeInsetsMake(0, 20, 0, 20);
    self.scrView.fontName = FONT_NAME;
    self.scrView.fontSize = FONT_SIZE;
    self.scrView.fontColor = FONT_COLOR;
    self.scrView.horizontalSpacing = HORIZONTAL_SPACING;
    self.scrView.verticalSpacing = VERTICAL_SPACING;
    self.scrView.buttonMargins = BUTTON_MARGINS;
    self.scrView.fixedLabelBackgroundColor = FIXED_LABEL_BACKGROUND_COLOR;
    self.scrView.movableLabelBackgroundColor = MOVABLE_LABEL_BACKGROUND_COLOR;
    self.scrView.ghostLabelBackgroundColor = GHOST_LABEL_BACKGROUND_COLOR;
    
    
    [self.contentStackView addSubview:self.scrView];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(scrView)]];
//
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(scrView)]];

    
    
    self.scrView.string = [self _scrString];
    
//    self.scrView.string = @"[check] [-] [in] [-] [desk] [-] [super] [-] [toll]";
    
    [self.scrView createView];
}


- (NSString*) instruction {
    
    ExerciseType type = [self.exerciseDict[@"type"] integerValue];
    
    if (type == RANDOM_VOC_SINGLE) {

        return @"Bringe die Übersetzung in die richtige Reihenfolge";
    }
    else {
        
        return [super instruction];
    }
}


- (NSString*) _scrString {
    
    ExerciseType type = [self.exerciseDict[@"type"] integerValue];
    
    if (type == RANDOM_VOC_SINGLE) {
        
        NSInteger vocabularyID = [self.exerciseDict[@"lines"][0][@"field1"] integerValue];
        Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];
        
        NSString* prefix = vocabulary.prefixLang1;
        NSString* text = vocabulary.textLang1;
        
        
        NSMutableArray* components = [NSMutableArray array];
        
        if (prefix) {
            
            [components addObject:prefix];
        }
        
        NSScanner* scanner = [[NSScanner alloc] initWithString:text];
        NSCharacterSet* wordSet = [NSCharacterSet alphanumericCharacterSet];
        NSCharacterSet* punctuationSet = [NSCharacterSet punctuationCharacterSet];
        NSMutableCharacterSet* bothSet = [[NSMutableCharacterSet alloc] init];
        [bothSet formUnionWithCharacterSet:wordSet];
        [bothSet formUnionWithCharacterSet:punctuationSet];
        scanner.charactersToBeSkipped = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSLog(@"SCR: scanning vocabulary string: %@", text);
        
        while (![scanner isAtEnd]) {
            
            [scanner scanUpToCharactersFromSet:bothSet intoString:nil];
            
            NSString* string;
            
            [scanner scanCharactersFromSet:wordSet intoString:&string];
            
            if (!string || string.length == 0) {
                
                [scanner scanCharactersFromSet:punctuationSet intoString:&string];
            }
            
            if (string) {
                
                NSLog(@"word/punct: %@", string);
            }
            else {
                
                NSLog(@"!! NO WORD/PUNCT SCANNED (continues scanning)");
            }
            
            NSString* component = [NSString stringWithFormat:@"[%@]", string];
            
            [components addObject:component];
        }
        
        NSString* joinedString = [components componentsJoinedByString:@" "];
        
        NSLog(@"joined string: %@", joinedString);
        
        return joinedString;

    }

    else {
        
        NSDictionary* firstLine = self.exerciseDict[@"lines"][0];
        return firstLine[@"field1"];
    }
}


- (void) check {
    
    [super check];
    
    BOOL correct = [self.scrView check];
    NSInteger score = self.scrView.scoreAfterCheck;
    NSInteger maxScore = self.scrView.maxScore;
    
    [self setScore:score ofMaxScore:maxScore];
    
    
    if (correct) {
        
        [self playCorrectSound];
        
        UIView* checkView = [[UINib nibWithNibName:@"ExerciseCheckView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil][0];
        
        [self.contentStackView addSubview:checkView];
        [self.contentStackView setNeedsUpdateConstraints];
    }
    else {
        
        [self playWrongSound];
        
        ExerciseCorrectionView* correctionView = [[ExerciseCorrectionView alloc] init];
        correctionView.layoutMargins = UIEdgeInsetsMake(0, 20, 0, 20);
        correctionView.strings = @[[self.scrView correctionString]];
        
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
