//
//  ExerciseCorrectionView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExerciseTextScanner.h"
#import "StackView.h"


@interface ExerciseCorrectionView : UIView <ExerciseTextScannerDelegate> {
    
    NSMutableAttributedString* _textString;
    
    NSDictionary* _normalAttributes;
    NSDictionary* _boldAttributes;
}

@property (nonatomic, copy) NSArray* strings;

@property (nonatomic, assign) BOOL tabular;

@property (nonatomic, strong) IBOutlet StackView* textContainer;


- (void) createView;

@end
