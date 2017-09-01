//
//  ExerciseTextScanner.h
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 11.12.13.
//  Copyright (c) 2013 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseTextScannerDelegate.h"


typedef enum {

    ExerciseTextScannerCharacterTypeUnknown,
    ExerciseTextScannerCharacterTypeAlphaNumerical,
    ExerciseTextScannerCharacterTypePunctuation,
    ExerciseTextScannerCharacterTypeWhitespace,
    ExerciseTextScannerCharacterTypeNewline,
    ExerciseTextScannerCharacterTypeGap,
    ExerciseTextScannerCharacterTypeControl
    
} ExerciseTextScannerCharacterType;


typedef enum {
    
    ExerciseTextScannerControlTypeUnknown,
    ExerciseTextScannerControlTypeNewline
    
} ExerciseTextScannerControlType;



@interface ExerciseTextScanner : NSObject {
    
    NSScanner* _scanner;
    NSAttributedString* _attributedString;
    
    NSCharacterSet* _whitespaceSet;
    NSCharacterSet* _newlineSet;
    NSCharacterSet* _alphanumericalSet;
    NSCharacterSet* _punctuationSet;
    NSCharacterSet* _gapOrControlCharSet;
    NSMutableCharacterSet* _wordStopSet;
}

@property (nonatomic, assign) id<ExerciseTextScannerDelegate> delegate;


- (void) scanAttributedString:(NSAttributedString*) attributedString;

- (BOOL) isAtEnd;

@end
