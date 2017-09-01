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


@interface ExerciseDragAndDropView : ReorderableLineLayoutView <ExerciseTextScannerDelegate> {
    
    ExerciseTextScanner* _scanner;
    NSMutableArray* _components;
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


- (void) createView;

@end
