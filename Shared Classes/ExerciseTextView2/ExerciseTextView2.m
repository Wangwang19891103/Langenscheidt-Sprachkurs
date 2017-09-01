//
//  ExerciseTextView2.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExerciseTextView2.h"
#import "NSMutableAttributedString+HTML.h"
#import "ExerciseTextField.h"
#import "NSAttributedString+Extensions.h"
#import "CGExtensions.h"
#import "NSArray+Extensions.h"
#import "NSString+Clean.h"
#import "LineLayoutSpaceView.h"
#import "NSMutableAttributedString+Clean.h"
#import "ExerciseTypes.h"



#define FONT_NAME           @"HelveticaNeue-Bold"
#define FONT_SIZE           20.0f
#define FONT_COLOR          [UIColor blackColor]
#define LINE_SPACING        5.0f
//#define TEXT_FIELD_HEIGHT   16.0f
//#define TEXT_FIELD_BORDER_COLOR     [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]
//#define TEXT_FIELD_BORDER_COLOR_WRONG     [UIColor colorWithRed:210/255.0 green:17/255.0 blue:17/255.0 alpha:1.0]
//#define TEXT_FIELD_BORDER_COLOR_SELECTED        [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]
//#define TEXT_FIELD_BACKGROUND_COLOR     [UIColor clearColor]
//#define TEXT_FIELD_BACKGROUND_COLOR_CORRECT     [UIColor clearColor]
//#define TEXT_FIELD_BACKGROUND_COLOR_WRONG       [UIColor clearColor]
#define TEXT_FIELD_INSETS           UIEdgeInsetsMake(3,5,3,5)
#define TEXT_FIELD_BORDER_WIDTH     2.0f
//#define TEXT_FIELD_TEXT_COLOR   [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]
//#define TEXT_FIELD_TEXT_COLOR_WRONG   [UIColor colorWithRed:210/255.0 green:17/255.0 blue:17/255.0 alpha:1.0]

#define HORIZONTAL_SPACING          0
#define VERTICAL_SPACING            0
#define VERTICAL_ALIGNMENT          NSLayoutFormatAlignAllCenterY
#define SPACE_WIDTH                 5

#define ITEM_HEIGHT         24.0f

#define SOLUTION_DELIMITERS     @"|ǀ"


#define SCORE_PER_TEXTFIELD         1
#define SCORE_STANDARDKEYBOARD      4
#define SCORE_STANDARDKEYBOARD_LISTENINGCOMPREHENSION      10
#define SCORE_CUSTOMKEYBOARD        3
#define SCORE_CUSTOMKEYBOARD_LISTENINGCOMPREHENSION        7
#define SCORE_DND                   2



@implementation ExerciseTextView2

@synthesize delegate;

@synthesize string;
@synthesize fontName;
@synthesize fontSize;
//@synthesize fontColor;
//@synthesize textFieldAdjustmentY;
@synthesize lineSpacing;
//@synthesize textFieldHeight;
//@synthesize textFieldAdjustmentWidth;
//@synthesize textFieldBorderColor;
//@synthesize textFieldBackgroundColor;
//@synthesize textFieldBackgroundColorCorrect;
//@synthesize textFieldBackgroundColorWrong;
//@synthesize textFieldBorderColorSelected;
//@synthesize textFieldBorderColorCorrect;
//@synthesize textFieldBorderColorWrong;
@synthesize textFieldInsets;
@synthesize resizeToActualWidth;

@synthesize inputType;
@synthesize generateSharedSolutions;



#pragma mark - Init

- (id) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    [self initialize];
    
    return self;
}


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
    
    [super initialize];
    
    self.textFields = [NSMutableArray array];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.fontName = FONT_NAME;
    self.fontSize = FONT_SIZE;
    self.textColor = FONT_COLOR;
    self.lineSpacing = LINE_SPACING;
//    self.textFieldHeight = TEXT_FIELD_HEIGHT;
    
//    self.textFieldTextColor = TEXT_FIELD_TEXT_COLOR;
//    self.textFieldTextColorSelected = TEXT_FIELD_TEXT_COLOR;
//    self.textFieldTextColorCorrect = TEXT_FIELD_TEXT_COLOR;
//    self.textFieldTextColorWrong = TEXT_FIELD_TEXT_COLOR_WRONG;
//    
//    self.textFieldBorderColor = TEXT_FIELD_BORDER_COLOR;
//    self.textFieldBorderColorSelected = TEXT_FIELD_BORDER_COLOR_SELECTED;
//    self.textFieldBorderColorCorrect = TEXT_FIELD_BORDER_COLOR;
//    self.textFieldBorderColorWrong = TEXT_FIELD_BORDER_COLOR_WRONG;
//    self.textFieldBackgroundColor = TEXT_FIELD_BACKGROUND_COLOR;
//    self.textFieldBackgroundColorCorrect = TEXT_FIELD_BACKGROUND_COLOR_CORRECT;
//    self.textFieldBackgroundColorWrong = TEXT_FIELD_BACKGROUND_COLOR_WRONG;
    self.textFieldInsets = TEXT_FIELD_INSETS;
    
    self.horizontalSpacing = HORIZONTAL_SPACING;
    self.verticalSpacing = VERTICAL_SPACING;
    self.verticalAlignment = VERTICAL_ALIGNMENT;
    
    self.textFieldsCanBeTapped = YES;
    
    _solutionDelimiterSet = [NSCharacterSet characterSetWithCharactersInString:SOLUTION_DELIMITERS];
    
    _maxScore = 0;
 
}



#pragma mark - Setters

- (void) setString:(NSString *)p_string {
    
    string = [p_string cleanString];
    
}


#pragma mark - View, Layout, Constraints

- (void) createView {

    [self _createTextFieldVisualDictionary];
    
    NSDictionary* attributes = @{
                                 NSFontAttributeName : [UIFont fontWithName:self.fontName size:self.fontSize],
                                 NSForegroundColorAttributeName : self.textColor
                                 };

    NSDictionary* italicAttributes = @{
                                 NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Italic" size:self.fontSize],
                                 NSForegroundColorAttributeName : [UIColor colorWithWhite:0.33 alpha:1.0]
                                 };

     NSDictionary*(^attributesBlock)(NSString*) = nil;
     
     if (_parseParantheses) {
         
         attributesBlock = ^NSDictionary *(NSString *tagName) {
             
             if ([tagName isEqualToString:@"i"]) {
                 
                 return italicAttributes;
             }
             else return nil;
         };
     }

    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:self.string attributes:attributes];
    [attributedString parseHTMLWithCustomAttributesBlock:attributesBlock];

    attributedString = [attributedString cleanAttributedString];
    
     
     
    [self.textFields removeAllObjects];
    
    _numberOfSubviewsParsed = 0;
    ExerciseTextScanner* scanner = [[ExerciseTextScanner alloc] init];
    scanner.delegate = self;
    [scanner scanAttributedString:attributedString];

    // Special case for DND: each text field only has one solution -> the solutions of all text fields together are available for any text field
    
    // check if the case stands
    
    if (self.generateSharedSolutions) {
        
        BOOL isDNDSpecialCase = YES;
        
        for (ExerciseTextField* textField in self.textFields) {
            
            if (textField.solutionStrings.count > 1) {
                
                isDNDSpecialCase = NO;
                break;
            }
        }
        
        if (isDNDSpecialCase) {
            
            NSMutableArray* newSolutionStrings = [NSMutableArray array];

            for (ExerciseTextField* textField in self.textFields) {
            
                [newSolutionStrings addObject:textField.solutionStrings[0]];
            }

//            NSArray* a = [NSArray randomizedArrayFromArray:newSolutionStrings];
            
            for (ExerciseTextField* textField in self.textFields) {

                NSMutableArray* newSolutions = [NSMutableArray array];
                
                [newSolutions addObject:textField.solutionStrings.firstObject];  // add own solution as first object (= correct answer)
                
                // add other solutions
                
                for (NSString* otherSolution in newSolutionStrings) {
                    
                    if (![newSolutions containsObject:otherSolution]) {
                        
                        [newSolutions addObject:otherSolution];
                    }
                }
                
                textField.solutionStrings = newSolutions;
            }
        }
    }
    
    
}


- (void) _createTextFieldVisualDictionary {
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];

    
    
    dict[kExerciseTextFieldStateNew] = @{
                                         kExerciseTextFieldTextColor : self.textFieldTextColorFinished,
                                         kExerciseTextFieldBackgroundColor : self.textFieldBackgroundColorFinished,
                                         kExerciseTextFieldBorderColor : self.textFieldBorderColorFinished
                                         };

    dict[kExerciseTextFieldStateActive] = @{
                                            kExerciseTextFieldTextColor : self.textFieldTextColorActive,
                                            kExerciseTextFieldBackgroundColor : self.textFieldBackgroundColorActive,
                                            kExerciseTextFieldBorderColor : self.textFieldBorderColorActive
                                            };
    
    dict[kExerciseTextFieldStateFinished] = @{
                                              kExerciseTextFieldTextColor : self.textFieldTextColorFinished,
                                              kExerciseTextFieldBackgroundColor : self.textFieldBackgroundColorFinished,
                                              kExerciseTextFieldBorderColor : self.textFieldBorderColorFinished
                                              };
    
    dict[kExerciseTextFieldStateCorrect] = @{
                                             kExerciseTextFieldTextColor : self.textFieldTextColorCorrect,
                                             kExerciseTextFieldBackgroundColor : self.textFieldBackgroundColorCorrect,
                                             kExerciseTextFieldBorderColor : self.textFieldBorderColorCorrect
                                             };
    
    dict[kExerciseTextFieldStateWrong] = @{
                                           kExerciseTextFieldTextColor : self.textFieldTextColorWrong,
                                           kExerciseTextFieldBackgroundColor : self.textFieldBackgroundColorWrong,
                                           kExerciseTextFieldBorderColor : self.textFieldBorderColorWrong
                                           };

    
    
    
//    dict[@"notChecked"] = @{
//                            @"textColor" : self.textFieldTextColor,
//                            @"textColorSelected" : self.textFieldTextColor,
//                            @"borderColor" : self.textFieldBorderColor,
//                            @"borderColorSelected" : self.textFieldBorderColorSelected
//                            };
//    dict[@"correct"] = @{
//                         @"textColor" : self.textFieldTextColorCorrect,
//                         @"textColorSelected" : self.textFieldTextColorCorrect,
//                         @"borderColor" : self.textFieldBorderColorCorrect,
//                         @"borderColorSelected" : self.textFieldBorderColorSelected
//                         };
//    dict[@"wrong"] = @{
//                       @"textColor" : self.textFieldTextColorWrong,
//                       @"textColorSelected" : self.textFieldTextColorWrong,
//                       @"borderColor" : self.textFieldBorderColorWrong,
//                       @"borderColorSelected" : self.textFieldBorderColorSelected
//                       };
    
    _textFieldVisualDictionary = dict;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    
}




#pragma mark - LineLayoutView3

- (void) addConnectionToken {
    
    [super addConnectionToken];
    
    _lastSubviewType = ConnectionToken;
}









#pragma mark - Scanner delegate

- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanWordString:(NSAttributedString *)attributedString {
    
    CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];

    UILabel* label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.attributedText = attributedString;
    label.numberOfLines = 0;
    
    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(width)]" options:0 metrics:@{@"width" : @(ceil(textRect.size.width))} views:NSDictionaryOfVariableBindings(label)]];
//    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(width@500)]" options:0 metrics:@{@"width" : @(ceil(textRect.size.width))} views:NSDictionaryOfVariableBindings(label)]];
    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(height)]" options:0 metrics:@{@"height" : @(ITEM_HEIGHT)} views:NSDictionaryOfVariableBindings(label)]];
    
    [self addSubview:label];
    
    ++_numberOfSubviewsParsed;
    
    _lastSubviewType = WordString;
}


- (void) exerciseTextScannerDidScanNewline:(ExerciseTextScanner *)scanner {
    
//    UIView* view = [[ExerciseTextViewNewlineView alloc] init];
//    view.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(0)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(view)]];
//    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[view(0)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(view)]];
//    
//    [self addSubview:view];
    
    _lastSubviewType = Newline;
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanGapWithString:(NSAttributedString *)p_attributedString {

    BOOL shouldAlignLeft = NO;

    
    
    // connect textfield with word before if there was no whitespace in between
    
    if (_lastSubviewType == WordString) {
        
        [self addConnectionToken];
        
        shouldAlignLeft = YES;
    }
    
    
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:p_attributedString];
    
    // code for rendering different states in Interface Builder
    
#if TARGET_INTERFACE_BUILDER
    
    ExerciseControlSolutionState debugSolutionState = ExerciseControlSolutionStateNotChecked;
    
    if ([[attributedString.string substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"@c"]) {
        
        debugSolutionState = ExerciseControlSolutionStateCorrect;
        [attributedString replaceCharactersInRange:NSMakeRange(0, 2) withString:@""];
    }
    else if ([[attributedString.string substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"@w"]) {
        
        debugSolutionState = ExerciseControlSolutionStateWrong;
        [attributedString replaceCharactersInRange:NSMakeRange(0, 2) withString:@""];
    }
    
#endif
    
    // ---
    
    NSArray* solutions = [attributedString.string componentsSeparatedByCharactersInSet:_solutionDelimiterSet];
    CGSize maxSize = CGSizeZero;
    NSMutableArray* solutionStrings = [NSMutableArray array];
    
//    NSLog(@"solutions: %@", solutions);
    
    for (NSString* solution in solutions) {
//
//        CGSize size = [solution boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
//        
//        maxSize = CGSizeMax(maxSize, size);
//        
        [solutionStrings addObject:solution];
    }
    
    //    ExerciseGapTextField* textField = [[ExerciseGapTextField alloc] initWithFrame:CGRectMake(0, 0, maxSize.width + TEXTFIELD_ADJUSTMENT_WIDTH, [ExerciseGapTextField preferredHeight])];
    
    //    textField.solutions = solutionStrings;
    
    ExerciseTextField* textField = [[ExerciseTextField alloc] init];
    textField.solutionStrings = solutionStrings;
    textField.font = [UIFont fontWithName:self.fontName size:self.fontSize];
    textField.stateVisualDictionary = _textFieldVisualDictionary;
    textField.inputType = inputType;
    textField.scrollContainerView = self;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
//    textField.textColor = TEXT_FIELD_TEXT_COLOR;
    textField.insets = self.textFieldInsets;
    textField.height = ITEM_HEIGHT;
    textField.userInteractionEnabled = self.textFieldsCanBeTapped;

    ExerciseTextField* lastTextField = nil;
    BOOL disableStandard = [self _lastSubviewWasTextField:&lastTextField];
    
    if (disableStandard) {
        
        textField.disableStandard = YES;
        lastTextField.disableStandard = YES;
    }
    
    maxSize = CGSizeOutset(maxSize, self.textFieldInsets);
    
//    [textField addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[textField(width)]" options:0 metrics:@{@"width" : @(maxSize.width)} views:NSDictionaryOfVariableBindings(textField)]];
//    [textField addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textField(height)]" options:0 metrics:@{@"height" : @(maxSize.height)} views:NSDictionaryOfVariableBindings(textField)]];

    
    if (shouldAlignLeft) {
        
        textField.textAlignment = NSTextAlignmentLeft;
    }
    
    
#if TARGET_INTERFACE_BUILDER
    
    textField.text = solutionStrings[0];
    textField.solutionState = debugSolutionState;
    
#endif
    
    [self addSubview:textField];
    [self.textFields addObject:textField];
    
//    _type = [self.exerciseDict[@"type"] integerValue];
    
// logical dividing of exercisetypes. To do this, use inputTypeForExerciseType class method of Exercisetypes class.
    
    inputType = [ExerciseTypes inputTypeForExerciseType:_type];
    
    if(inputType == ExerciseInputTypeStandard){
        
        _maxScore += SCORE_STANDARDKEYBOARD;
        _maxScore_Listening += SCORE_STANDARDKEYBOARD_LISTENINGCOMPREHENSION;
    }
    else if(inputType == ExerciseInputTypeScrambledLetters){
        
        _maxScore += SCORE_CUSTOMKEYBOARD;
        _maxScore_Listening += SCORE_CUSTOMKEYBOARD_LISTENINGCOMPREHENSION;
    }
    else if (inputType == ExerciseInputTypeDragAndDrop){
        
        _maxScore += SCORE_DND;
    }
    else{
        
        _maxScore += SCORE_PER_TEXTFIELD;
    }

    ++_numberOfSubviewsParsed;

    _lastSubviewType = Gap;
}


- (BOOL) _lastSubviewWasTextField:(ExerciseTextField**) lastTextField {  //OPTIMIZE

    if (self.subviews.count == 0) return NO;
    
    
    BOOL wasTextField = NO;
    UIView* subview = nil;
    NSInteger index = self.subviews.count - 1;
    
    
    do {
        
        subview = self.subviews[index];
        
        if (![self viewIsControlToken:subview]) {
            
            if ([subview isKindOfClass:[ExerciseTextField class]]) {
                
                *lastTextField = (ExerciseTextField*)subview;
                return YES;
            }
            else {
                
                return NO;
            }
        }
        
        index--;
        
    } while (index >= 0);
    
    
    return wasTextField;
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanPunctuationString:(NSAttributedString *)attributedString {
    
    
    if (_numberOfSubviewsParsed > 0) {
    
        [self addConnectionToken];
    }
    
    [self exerciseTextScanner:scanner didScanWordString:attributedString];
    
    ++_numberOfSubviewsParsed;

    _lastSubviewType = Punctuation;
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanWhitespaceString:(NSAttributedString *)attributedString {
    
    [self addNonBreakingSpaceWithWidth:SPACE_WIDTH];
    
    ++_numberOfSubviewsParsed;
    
    _lastSubviewType = Whitespace;
}


- (BOOL) check {
    
    BOOL correct = YES;
    NSInteger score = 0;
    NSInteger score_Listening = 0;
    
    self.userInteractionEnabled = NO;
    
    for (ExerciseTextField* textField in self.textFields) {
        
        if (![textField check]) {
            
            correct = NO;
        }
        else {
            
            switch (_type) {
                case LTXT_STANDARD:
                    NSLog(@"standard is called");
                    break;
                case LTXT_CUSTOM:
                    NSLog(@"custom is called");
                    break;
                case DND:
                    NSLog(@"drag and drop");
                    break;
                default:
                    break;
            }
            
// logical dividing of exercisetypes. To do this, use inputTypeForExerciseType class method of Exercisetypes class.
            
            inputType = [ExerciseTypes inputTypeForExerciseType:_type];
            
            if(inputType == ExerciseInputTypeStandard){
                
                score += SCORE_STANDARDKEYBOARD;
                score_Listening += SCORE_STANDARDKEYBOARD_LISTENINGCOMPREHENSION;
            }
            else if(inputType == ExerciseInputTypeScrambledLetters){
                
                score += SCORE_CUSTOMKEYBOARD;
                score_Listening += SCORE_CUSTOMKEYBOARD_LISTENINGCOMPREHENSION;
            }
            else if (inputType == ExerciseInputTypeDragAndDrop){
                
                score += SCORE_DND;
            }
            else{
                
                score += SCORE_PER_TEXTFIELD;
            }
        }
    }
    _scoreAfterCheck = score;
    _scoreAfterCheck_Listening = score_Listening;
    
    NSLog(@"score is called into: %ld", (long)score);
    
    return correct;
}




#pragma mark - Interface Builder

- (void) prepareForInterfaceBuilder {
    
    [self createView];
}




- (NSString*) description {
    
    return [NSString stringWithFormat:@"ExerciseTextView2 '%@' (%@)",self.string, NSStringFromCGRect(self.frame)];
}


@end
