//
//  ExerciseTextScannerDelegate.h
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 12.12.13.
//  Copyright (c) 2013 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ExerciseTextScanner;

@protocol ExerciseTextScannerDelegate <NSObject>

- (void) exerciseTextScanner:(ExerciseTextScanner*) scanner didScanWordString:(NSAttributedString*) attributedString;
- (void) exerciseTextScanner:(ExerciseTextScanner*) scanner didScanPunctuationString:(NSAttributedString*) attributedString;
- (void) exerciseTextScanner:(ExerciseTextScanner*) scanner didScanWhitespaceString:(NSAttributedString*) attributedString;
- (void) exerciseTextScanner:(ExerciseTextScanner*) scanner didScanGapWithString:(NSAttributedString*) attributedString;
- (void) exerciseTextScannerDidScanNewline:(ExerciseTextScanner*) scanner;

@end
