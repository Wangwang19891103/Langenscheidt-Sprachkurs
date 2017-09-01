//
//  ExerciseTextView2.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LineLayoutView3.h"
#import "ExerciseTextViewDelegate.h"
#import "ExerciseTextScanner.h"
#import "ExerciseTypes.h"
#import "UIColor+ProjectColors.h"
#import "ExerciseViewController.h"



typedef NS_ENUM(NSInteger, LastSubviewType) {
    
    None,
    WordString,
    Newline,
    Gap,
    Punctuation,
    Whitespace,
    ConnectionToken
};



IB_DESIGNABLE


@interface ExerciseTextView2 : LineLayoutView3 <ExerciseTextScannerDelegate, ExerciseTextViewDelegate> {
    
    NSDictionary* _textFieldVisualDictionary;

    NSCharacterSet* _solutionDelimiterSet;
    
    BOOL _numberOfSubviewsParsed;

    LastSubviewType _lastSubviewType;
    
    ExerciseType _type;
    
//    typedef NS_ENUM(NSInteger, ExerciseInputType)* inputType;
    
}


@property (assign) id<ExerciseTextViewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray* textFields;

@property (nonatomic, copy) IBInspectable NSString* string;

@property (nonatomic, copy)  IBInspectable NSString* fontName;

@property (nonatomic, assign)  IBInspectable CGFloat fontSize;

@property (nonatomic, strong)  IBInspectable UIColor* textColor;

//@property (nonatomic, assign)  IBInspectable CGFloat textFieldAdjustmentY;

@property (nonatomic, assign)  IBInspectable CGFloat lineSpacing;

@property (nonatomic, assign)  IBInspectable CGFloat textFieldHeight;

//@property (nonatomic, assign) IBInspectable CGFloat textFieldAdjustmentWidth;

@property (nonatomic, assign) UIEdgeInsets textFieldInsets;

@property (nonatomic, assign) BOOL parseParantheses;



// text field properties

// active state

@property (nonatomic, strong) IBInspectable UIColor* textFieldTextColorActive;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColorActive;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColorActive;

// finished state

@property (nonatomic, strong) IBInspectable UIColor* textFieldTextColorFinished;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColorFinished;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColorFinished;

// correct state

@property (nonatomic, strong) IBInspectable UIColor* textFieldTextColorCorrect;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColorCorrect;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColorCorrect;

// wrong state

@property (nonatomic, strong) IBInspectable UIColor* textFieldTextColorWrong;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColorWrong;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColorWrong;








//@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColor;
//
//@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColor;
//
//@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColorCorrect;
//
//@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColorWrong;
//
//@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColorSelected;
//
//@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColorCorrect;
//
//@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColorWrong;
//
//@property (nonatomic, strong) UIColor* textFieldTextColor;
//
//@property (nonatomic, strong) UIColor* textFieldTextColorSelected;
//
//@property (nonatomic, strong) UIColor* textFieldTextColorCorrect;
//
//@property (nonatomic, strong) UIColor* textFieldTextColorWrong;

@property (nonatomic, assign) ExerciseInputType inputType;

@property (nonatomic, assign) BOOL generateSharedSolutions;

@property (nonatomic, assign) BOOL resizeToActualWidth;

@property (nonatomic, assign) BOOL textFieldsCanBeTapped;

@property (nonatomic, readonly) NSInteger scoreAfterCheck;

@property (nonatomic, readonly) NSInteger maxScore;

/***   this part was added   ***/
@property (nonatomic, readonly) NSInteger scoreAfterCheck_Listening;
@property (nonatomic, readonly) NSInteger maxScore_Listening;


- (void) createView;

- (BOOL) check;

@end
