//
//  ExerciseTextView.h
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 11.12.13.
//  Copyright (c) 2013 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseTextScanner.h"
//#import "ExerciseControl.h"
#import "ExerciseTextViewDelegate.h"
#import "ExerciseTypes.h"
@import UIKit;


IB_DESIGNABLE


@interface ExerciseTextView : UIView <ExerciseTextScannerDelegate> {
    
    NSMutableArray* _components;
    
    NSDictionary* _textFieldVisualDictionary;
}

@property (assign) id<ExerciseTextViewDelegate> delegate;

//@property (nonatomic, copy) NSAttributedString* attributedString;

@property (nonatomic, strong) NSMutableArray* textFields;

@property (nonatomic, copy) IBInspectable NSString* string;

@property (nonatomic, copy)  IBInspectable NSString* fontName;

@property (nonatomic, assign)  IBInspectable CGFloat fontSize;

@property (nonatomic, strong)  IBInspectable UIColor* fontColor;

@property (nonatomic, assign)  IBInspectable CGFloat textLayerAdjustmentY;

@property (nonatomic, assign)  IBInspectable CGFloat lineSpacing;

@property (nonatomic, assign)  IBInspectable CGFloat textFieldHeight;

@property (nonatomic, assign) IBInspectable CGFloat textFieldAdjustmentWidth;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColor;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColor;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColorCorrect;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBackgroundColorWrong;

@property (nonatomic, strong) IBInspectable UIColor* textFieldBorderColorSelected;

@property (nonatomic, assign) ExerciseInputType inputType;

@property (nonatomic, assign) BOOL generateSharedSolutions;

- (void) createView;

@end
