//
//  ExerciseDragAndDropView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExerciseTextScanner.h"
#import "ReorderableLineLayoutView.h"


IB_DESIGNABLE


@interface SCRView : ReorderableLineLayoutView <ExerciseTextScannerDelegate> {
    
    ExerciseTextScanner* _scanner;
    NSMutableArray* _components;
    NSArray* _correctOrder;
}

@property (nonatomic, copy) IBInspectable NSString* string;

@property (nonatomic, copy) IBInspectable NSString* fontName;

@property (nonatomic, assign) IBInspectable CGFloat fontSize;

@property (nonatomic, strong) IBInspectable UIColor* fontColor;

@property (nonatomic, assign) IBInspectable CGFloat horizontalSpacing;

@property (nonatomic, assign) IBInspectable CGFloat verticalSpacing;

@property (nonatomic, assign) IBInspectable CGFloat
buttonMargins;

@property (nonatomic, strong) IBInspectable UIColor* fixedLabelBackgroundColor;

@property (nonatomic, strong) IBInspectable UIColor* movableLabelBackgroundColor;

@property (nonatomic, strong) IBInspectable UIColor* ghostLabelBackgroundColor;

@property (nonatomic, readonly) NSInteger maxScore;

@property (nonatomic, readonly) NSInteger scoreAfterCheck;


- (void) createView;

- (BOOL) check;

- (NSString*) correctionString;

@end
