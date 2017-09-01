//
//  Exercise_LTXT_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Exercise_LTXT_ViewController.h"
#import "ExerciseTextField.h"
#import "NSString+Clean.h"
#import "VocabularyFormatter.h"
#import "UILabel+HTML.h"


#define TABULAR_SEPARATORS       @"–-"





//#define TEST_MODE





@implementation Exercise_LTXT_ViewController

@synthesize topTextLabel;
@synthesize contentStackView;
@synthesize audioFileName;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    
    _textFieldCoordinator = [[TextFieldCoordinator alloc] init];
    _textFieldCoordinator.delegate = self;
    
    
    self.canBeChecked = YES;
    self.hidesBottomButtonInitially = YES;
    
    
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
//    [self.contentStackView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //    [self.contentStackView addSubview:self.topTextView];

    
    _textFieldCoordinator.scrollView = self.exerciseNavigationController.scrollview;  // important, depends on the exercise type/layout mode

    
    
#ifdef TEST_MODE
    
    [self setTestContent];
    
#endif
    
    
    
    [self createViews];

    // audio button container
    
    if (self.exerciseDict[@"audioFile"]) {
        
        _player = [[DialogAudioPlayer alloc] initWithExerciseDict:self.exerciseDict];
        
        _audioButtonContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentStackView addSubview:_audioButtonContainer];
        
        [_audioButtonContainer layoutIfNeeded];
    }

}





- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    NSLog(@"LTXT - viewDidLayoutSubviews");
}


- (void) updateViewConstraints {
    
    NSLog(@"LTXT - updateViewContraints");
    
    [super updateViewConstraints];
}


- (void) createViews {
    
    NSLog(@"LTXT - createViews");
    
    
    NSString* toptext = self.exerciseDict[@"topText"];
    
    
    ExerciseType type = [self.exerciseDict[@"type"] integerValue];
    
    if (type == RANDOM_VOC_SINGLE) {
    
        NSInteger vocabularyID = [self.exerciseDict[@"lines"][0][@"field1"] integerValue];
        Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];
        
        NSString* leftString = [VocabularyFormatter formattedStringForLanguage:Lang2 withVocabulary:vocabulary];

        toptext = leftString;
    }
    
    
    
    if (toptext) {
        
        self.topTextLabel.text = toptext;
        [self.topTextLabel parseHTML];
    }
    else {

        [self.topTextContainer removeFromSuperview];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[contentStackView]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(contentStackView)]];
    }
    

    _type = [self.exerciseDict[@"type"] integerValue];
    
//    if (self.vocabularyDict) {
//        
//        _type = [self.vocabularyDict[@"type"] integerValue];
//    }
    
    _textViews = [NSMutableArray array];
    
    
    switch (_type) {
        case LTXT_STANDARD:
        case LTXT_CUSTOM:
        case DND:
        case RANDOM_VOC_SINGLE:

            [self _createViewsNormal];
            break;
            
        case LTXT_STANDARD_TABULAR:
        case LTXT_CUSTOM_TABULAR:
        case DND_TABULAR:
            
            [self _createViewsTabular];
            break;
            
        default:
            break;
    }
    
    
    [_textFieldCoordinator setFirstTextfieldActive];
}


- (NSString*)instruction {
    
    ExerciseType type = [self.exerciseDict[@"type"] integerValue];

    if (type == RANDOM_VOC_SINGLE) {
        
        return @"Schreibe die Übersetzung";
    }
    else {
        
        return [super instruction];
    }
}




- (void) _createViewsNormal {

    NSMutableArray* fieldStrings = [NSMutableArray array];
    
    ExerciseType type = [self.exerciseDict[@"type"] integerValue];
    
    if (type == RANDOM_VOC_SINGLE) {  // dead code
        
        NSInteger vocabularyID = [self.exerciseDict[@"lines"][0][@"field1"] integerValue];
        Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];
        
        NSString* rightString = [NSString stringWithFormat:@"%@%@",
                                 vocabulary.prefixLang1 ? [NSString stringWithFormat:@"%@ ", vocabulary.prefixLang1] : @"",
                                 [NSString stringWithFormat:@"[%@]", vocabulary.textLang1]
                                 ];
        
        [fieldStrings addObject:rightString];
    }
    
    else {
        
        NSDictionary* lineDict = self.exerciseDict[@"lines"][0];
        
        if (lineDict[@"field1"]) [fieldStrings addObject:lineDict[@"field1"]];
        if (lineDict[@"field2"]) [fieldStrings addObject:lineDict[@"field2"]];
        if (lineDict[@"field3"]) [fieldStrings addObject:lineDict[@"field3"]];
        if (lineDict[@"field4"]) [fieldStrings addObject:lineDict[@"field4"]];
        if (lineDict[@"field5"]) [fieldStrings addObject:lineDict[@"field5"]];
        
        
    }

    
    for (NSString* fieldString in fieldStrings) {
        
        NSLog(@"%@", fieldString);
        
        ExerciseTextView2* textView = [self newTextView];
        
        [self.contentStackView addSubview:textView];
        
        textView.string = fieldString;
        [textView createView];
        
        [_textFieldCoordinator addTextFields:textView.textFields];
        
//        [textView.textFields makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
        
        [_textViews addObject:textView];
    }

}


- (void) _createViewsTabular {
    
    NSMutableArray* fieldStrings = [NSMutableArray array];
    
    ExerciseType type = [self.exerciseDict[@"type"] integerValue];
    
    if (type == RANDOM_VOC_SINGLE) {  // dead code
        
        NSInteger vocabularyID = [self.exerciseDict[@"lines"][0][@"field1"] integerValue];
        Vocabulary* vocabulary = [[ContentDataManager instance] vocabularyWithID:vocabularyID];
        
        NSString* leftString = [VocabularyFormatter formattedStringForLanguage:Lang2 withVocabulary:vocabulary];
        NSString* rightString = [NSString stringWithFormat:@"%@%@",
                                 vocabulary.prefixLang1 ? [NSString stringWithFormat:@"%@ ", vocabulary.prefixLang1] : @"",
                                 [NSString stringWithFormat:@"[%@]", vocabulary.textLang1]
                                 ];
        
        // mask hyphons
        
        leftString = [leftString stringByReplacingOccurrencesOfString:@"-" withString:@"#HYPHON#"];
        rightString = [rightString stringByReplacingOccurrencesOfString:@"-" withString:@"#HYPHON#"];
        
        //-
        
        NSString* string = [NSString stringWithFormat:@"%@ - %@", leftString, rightString];
        
        [fieldStrings addObject:string];
    }
    
    else {
    
        NSDictionary* lineDict = self.exerciseDict[@"lines"][0];
        
        if (lineDict[@"field1"]) [fieldStrings addObject:lineDict[@"field1"]];
        if (lineDict[@"field2"]) [fieldStrings addObject:lineDict[@"field2"]];
        if (lineDict[@"field3"]) [fieldStrings addObject:lineDict[@"field3"]];
        if (lineDict[@"field4"]) [fieldStrings addObject:lineDict[@"field4"]];
        if (lineDict[@"field5"]) [fieldStrings addObject:lineDict[@"field5"]];
    }
    
    
    for (NSString* fieldString in fieldStrings) {

//        NSLog(@"%@", fieldString);
        
        NSArray* comps = [fieldString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:TABULAR_SEPARATORS]];

        NSString* leftString = [comps[0] cleanString];
        NSString* rightString = [comps[1] cleanString];
        
        // demask hyphons
        
        leftString = [leftString stringByReplacingOccurrencesOfString:@"#HYPHON#" withString:@"-"];
        rightString = [rightString stringByReplacingOccurrencesOfString:@"#HYPHON#" withString:@"-"];
        
        //-
        
        ExerciseTextView2* leftTextView = [self newTextView];
        leftTextView.accessibilityIdentifier = @"leftTextView";
        leftTextView.constrainSubviewWidth = YES;
        leftTextView.string = leftString;
        [leftTextView createView];
//        [leftTextView.textFields makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
        [_textFieldCoordinator addTextFields:leftTextView.textFields];

        ExerciseTextView2* rightTextView = [self newTextView];
        rightTextView.accessibilityIdentifier = @"rightTextView";
        rightTextView.constrainSubviewWidth = YES;
        rightTextView.string = rightString;
        [rightTextView createView];
//        [rightTextView.textFields makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
        [_textFieldCoordinator addTextFields:rightTextView.textFields];

        
        UIView* containerView = [[UIView alloc] init];
        containerView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [containerView addSubview:leftTextView];
        [containerView addSubview:rightTextView];
        
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[leftTextView(rightTextView)]-(0)-[rightTextView]-0-|" options:NSLayoutFormatAlignAllTop metrics:@{} views:NSDictionaryOfVariableBindings(leftTextView, rightTextView)]];
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[leftTextView]-(>=0)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(leftTextView)]];
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[rightTextView]-(>=0)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(rightTextView)]];
        
        [self.contentStackView addSubview:containerView];
        
        [_textViews addObject:leftTextView];
        [_textViews addObject:rightTextView];
    }

}


- (ExerciseTextView2*) newTextView {
    
    ExerciseTextView2* textView = [[ExerciseTextView2 alloc] init];
    textView.inputType = [ExerciseTypes inputTypeForExerciseType:_type];
    textView.layoutMargins = UIEdgeInsetsZero;
    textView.verticalSpacing = 5.0;
    textView.parseParantheses = YES;
    
    textView.textFieldTextColorActive = [UIColor projectBlueColor];
    textView.textFieldTextColorFinished = [UIColor projectBlueColor];
    textView.textFieldTextColorCorrect = [UIColor projectBlueColor];
    textView.textFieldTextColorWrong = [UIColor projectRedColor];
    
    textView.textFieldBackgroundColorActive = [UIColor whiteColor];
    textView.textFieldBackgroundColorFinished = [UIColor clearColor];
    textView.textFieldBackgroundColorCorrect = [UIColor clearColor];
    textView.textFieldBackgroundColorWrong = [UIColor clearColor];

    textView.textFieldBorderColorActive = [UIColor projectBlueColor];
    textView.textFieldBorderColorFinished = [UIColor projectBlueColor];
    textView.textFieldBorderColorCorrect = [UIColor projectBlueColor];
    textView.textFieldBorderColorWrong = [UIColor projectRedColor];
    
    if (textView.inputType == ExerciseInputTypeDragAndDrop) {
        
        textView.generateSharedSolutions = YES;
    }
    
    return textView;
}



#pragma mark - Check

- (void) check {
    
    [super check];
    
    NSMutableArray* strings = [NSMutableArray array];
    BOOL correct = YES;
    NSInteger score = 0;
    NSInteger maxScore = 0;
    
/*******      This part was changed by Petro.     ******/
    
    audioFileName = self.exerciseDict[@"audioFile"];
    NSLog(@"audiofilename is %@",audioFileName);

    [_textFieldCoordinator setLastTextfieldInactive];
    
    for (ExerciseTextView2* textView in _textViews) {
        
        if (![textView check]) {
        
            [strings addObject:textView.string];
            correct = NO;
        }
//        score += textView.scoreAfterCheck;
//        maxScore += textView.maxScore;
        
        if(audioFileName == NULL){
            
            score += textView.scoreAfterCheck;
            maxScore += textView.maxScore;
        }
        else{
            
            score += textView.scoreAfterCheck_Listening;
            
            NSLog(@"scoreAfterCheck_Listening %li",score);
            
            maxScore += textView.maxScore_Listening;
        }
/*********** end  *********/
    }
    
    
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
        correctionView.strings = strings;
        
        [correctionView createView];
        
        [self.contentStackView addSubview:correctionView];
        [self.contentStackView setNeedsUpdateConstraints];
//        [self.contentStackView layoutIfNeeded];
    }
    
    
    [self scrollBottomToVisible];
    
}






#pragma mark - TextFieldCoordinatorDelegate 

- (void) textFieldCoordinatorLastTextFieldDidFinish:(TextFieldCoordinator *)coordinator {
    
    // show check button
    
    [self showBottomButton];
}


- (BOOL) textFieldCoordinatorShouldSetLastTextFieldInactive:(TextFieldCoordinator *)coordinator {
    
    return NO;
}



#pragma mark - Stop

- (void) stop {
    
    [super stop];
    
    [_player stop];
}





#pragma mark - ___ test content

- (void) setTestContent {
    
//    {
//        dialogLines =     (
//        );
//        exerciseID = 0;
//        exerciseObject = "<Exercise: 0x7fb24262ef20> (entity: Exercise; id: 0xd0000000007c0012 <x-coredata://4E6EAA3E-7E1F-43B7-B54F-4215AF65E37A/Exercise/p31> ; data: {\n    audioFile = nil;\n    audioRange = nil;\n    cluster = \"0xd000000004cc000e <x-coredata://4E6EAA3E-7E1F-43B7-B54F-4215AF65E37A/ExerciseCluster/p307>\";\n    dialogLines = \"<relationship fault: 0x7fb2424ecda0 'dialogLines'>\";\n    explanation = \"Im Englischen gibt es den bestimmten Artikel <b>the</b> <i>der/die/das</i>, der immer unver\\U00e4ndert bleibt.\";\n    id = 0;\n    instruction = \"F\\U00fclle die L\\U00fccken.\";\n    lines = \"<relationship fault: 0x7fb2424ecf10 'lines'>\";\n    popupFile = nil;\n    topText = nil;\n    type = 2;\n})";
//        explanation = "Im Englischen gibt es den bestimmten Artikel <b>the</b> <i>der/die/das</i>, der immer unver\U00e4ndert bleibt.";
//        instruction = "F\U00fclle die L\U00fccken.";
//        lines =     (
//                     {
//                         field1 = "der S\U00fcden \U2013 [the] South";
//                         field2 = "die Marketingleiterin \U2013 [the] Head of Marketing";
//                         field3 = "das B\U00fcro \U2013 [the] office";
//                     }
//                     );
//        type = 2;
//    }

    self.exerciseDict = @{
                          @"type" : @(2),
                          @"lines" : @[
                                  @{
                                      @"field1" : @"Dies ist ein längerer [Satz] mit mehreren [Lücken] und vielen [Worten].",
                                      @"field2" : @"Dies ist ein längerer [Satz] mit mehreren [Lücken] und vielen [Worten].",
                                      @"field3" : @"Dies ist ein längerer [Satz] mit mehreren [Lücken] und vielen [Worten].",
                                      @"field4" : @"Dies ist ein längerer [Satz] mit mehreren [Lücken] und vielen [Worten].",
                                      @"field5" : @"Dies ist ein längerer [Satz] mit mehreren [Lücken] und vielen [Worten].",
                                      }
                                  ]
                          };
    
}



//#pragma  mark - UITextFieldDelegate
//
//- (void) textFieldDidBeginEditing:(UITextField *)textField {
//    
//    [(ExerciseTextField*)textField setSelected:YES];
//}
//
//- (void) textFieldDidEndEditing:(UITextField *)textField {
//    
//    [(ExerciseTextField*)textField setSelected:NO];
//}
//
//
//- (BOOL) textFieldShouldReturn:(UITextField *)textField {
//    
//    [self.view endEditing:YES];
//    
//    return NO;
//}





#pragma mark - Dealloc

- (void) dealloc {
    

}

- (IBAction)actionAudio:(id)sender {
    
    [_player playExerciseAudio];
}



@end
