//
//  ExerciseTextScanner.m
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 11.12.13.
//  Copyright (c) 2013 mobilinga. All rights reserved.
//

#import "ExerciseTextScanner.h"
#import "macros.h"


#define GAP_OPEN_CHAR           '['
#define GAP_CLOSE_CHAR          ']'
#define CONTROL_OPEN_CHAR       '<'
#define CONTROL_CLOSE_CHAR      '>'
#define CONTROL_STRING_NEWLINE  @"newline"



@implementation ExerciseTextScanner

@synthesize delegate;


- (id) init {
    
    self = [super init];

    _whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    _newlineSet = [NSCharacterSet newlineCharacterSet];
    _alphanumericalSet = [NSCharacterSet alphanumericCharacterSet];
    _punctuationSet = [NSCharacterSet punctuationCharacterSet];
    _gapOrControlCharSet = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"%c%c%c%c", GAP_OPEN_CHAR, GAP_CLOSE_CHAR, CONTROL_OPEN_CHAR, CONTROL_CLOSE_CHAR]];
    _wordStopSet = [[NSMutableCharacterSet alloc] init];
    [_wordStopSet formUnionWithCharacterSet:_whitespaceSet];
    [_wordStopSet formUnionWithCharacterSet:_gapOrControlCharSet];
    
    return self;
}


- (void) scanAttributedString:(NSAttributedString*) attributedString {
    
    _attributedString = [attributedString copy];
    _scanner = [[NSScanner alloc] initWithString:attributedString.string];
    _scanner.charactersToBeSkipped = nil;

    while (![_scanner isAtEnd]) {

        BOOL success = [self scanNextToken];
        
        if (!success) break;
    }
}


- (BOOL) isAtEnd {
    
    return [_scanner isAtEnd];
}


- (BOOL) scanNextToken {
    
    ExerciseTextScannerCharacterType type = [self characterTypeAtScanLocation];
    createMutableArray(components);
    NSAttributedString* whitespaceString = nil;
    BOOL success = TRUE;
    
    
    if (type == ExerciseTextScannerCharacterTypeGap) {
        
        NSAttributedString* wordString = [self scanGap];
        
        [delegate exerciseTextScanner:self didScanGapWithString:wordString];
    }
    else if (type == ExerciseTextScannerCharacterTypeControl) {
        
        ExerciseTextScannerControlType type = [self scanControl];
        
        switch (type) {
                
            case ExerciseTextScannerControlTypeNewline:
                [delegate exerciseTextScannerDidScanNewline:self];
                break;
                
                default:
                NSLog(@"ExerciseTextScanner - Error: Found unknown control string (position=%ld)", _scanner.scanLocation);
                success = false;
                break;
        }
    }
    else if (type == ExerciseTextScannerCharacterTypeAlphaNumerical || type == ExerciseTextScannerCharacterTypeUnknown) {  // treat Unknown like a normal word
        
        [components addObject:[self scanWord]];
        
        
        // check if theres a punctuation char right after the word (including whitespace chars in between)
        
        // scan all whitespace chars
        if (![_scanner isAtEnd] && [self characterTypeAtScanLocation] == ExerciseTextScannerCharacterTypeWhitespace) {
            
             whitespaceString = [self scanWhitespaces];
        }
        
        // check current char is punctuation
        if (![_scanner isAtEnd] && [self characterAtScanLocation] == ExerciseTextScannerCharacterTypePunctuation) {
            
            // add scanned whitespace chars to components
            if (whitespaceString) {

                [components addObject:whitespaceString];
            }
            
            whitespaceString = nil;
            
            // add punctuation char to components
            [components addObject:[self scanWord]];
            
            // scan all whitespace chars
            if (![_scanner isAtEnd] && [self characterTypeAtScanLocation] == ExerciseTextScannerCharacterTypeWhitespace) {
                
                whitespaceString = [self scanWhitespaces];
            }
        }
        
        NSMutableAttributedString* wordString = [[NSMutableAttributedString alloc] init];
        
        for (NSAttributedString* attributedString in components) {
            
            [wordString appendAttributedString:attributedString];
        }
        
        // send compoents and whitespaces to delegate
        [delegate exerciseTextScanner:self didScanWordString:wordString];
        
        if (whitespaceString) {

            [delegate exerciseTextScanner:self didScanWhitespaceString:whitespaceString];
        }
        
        success = TRUE;
    }
    else if (type == ExerciseTextScannerCharacterTypePunctuation) {
        
        NSAttributedString* wordString = [self scanWord];
        
        [delegate exerciseTextScanner:self didScanPunctuationString:wordString];
        
        if (![_scanner isAtEnd] && [self characterTypeAtScanLocation] == ExerciseTextScannerCharacterTypeWhitespace) {
            
            whitespaceString = [self scanWhitespaces];
            
            [delegate exerciseTextScanner:self didScanWhitespaceString:whitespaceString];
        }
        
        success = TRUE;
    }
    else if (type == ExerciseTextScannerCharacterTypeWhitespace) {
        
        whitespaceString = [self scanWhitespaces];
        
        [delegate exerciseTextScanner:self didScanWhitespaceString:whitespaceString];
    }
    else if (type == ExerciseTextScannerCharacterTypeNewline) {
        
        [self scanNewlines];
        
        [delegate exerciseTextScannerDidScanNewline:self];
    }
    else if (type == ExerciseTextScannerCharacterTypeUnknown) {

        
        
        NSLog(@"ExerciseTextScanner - Error: Found unknown character (char='%C', position=%d", [self characterAtScanLocation], _scanner.scanLocation);
        
        success = FALSE;
    }
    
    return success;
}


#pragma mark - Next token

- (unichar) characterAtScanLocation {
    
    return [_attributedString.string characterAtIndex:_scanner.scanLocation];
}


- (ExerciseTextScannerCharacterType) characterTypeAtScanLocation {
    
    unichar c = [self characterAtScanLocation];
    
    if (c == GAP_OPEN_CHAR) return ExerciseTextScannerCharacterTypeGap;
    else if (c == CONTROL_OPEN_CHAR) return ExerciseTextScannerCharacterTypeControl;
    else if ([_alphanumericalSet characterIsMember:c]) return ExerciseTextScannerCharacterTypeAlphaNumerical;
    else if ([_punctuationSet characterIsMember:c]) return ExerciseTextScannerCharacterTypePunctuation;
    else if ([_newlineSet characterIsMember:c]) return ExerciseTextScannerCharacterTypeNewline;
    else if ([_whitespaceSet characterIsMember:c]) return ExerciseTextScannerCharacterTypeWhitespace;
    else return ExerciseTextScannerCharacterTypeUnknown;
}

    

- (NSAttributedString*) scanWord {
    
    uint location = _scanner.scanLocation;
    
    [_scanner scanUpToCharactersFromSet:_wordStopSet intoString:nil];
    
    uint length = _scanner.scanLocation - location;
    
    return [_attributedString attributedSubstringFromRange:NSMakeRange(location, length)];
}


- (NSAttributedString*) scanWhitespaces {
    
    uint location = _scanner.scanLocation;
    
    [_scanner scanCharactersFromSet:_whitespaceSet intoString:nil];
    
    uint length = _scanner.scanLocation - location;
    
    return [_attributedString attributedSubstringFromRange:NSMakeRange(location, length)];
}


- (NSAttributedString*) scanGap {

    [_scanner scanString:[NSString stringWithFormat:@"%c", GAP_OPEN_CHAR] intoString:nil];
    
    uint location = _scanner.scanLocation;
    
    [_scanner scanUpToString:[NSString stringWithFormat:@"%c", GAP_CLOSE_CHAR] intoString:nil];
    
    uint length = _scanner.scanLocation - location;
    
    [_scanner scanString:[NSString stringWithFormat:@"%c", GAP_CLOSE_CHAR] intoString:nil];
    
    return [_attributedString attributedSubstringFromRange:NSMakeRange(location, length)];
}


- (ExerciseTextScannerControlType) scanControl {
    
    [_scanner scanString:[NSString stringWithFormat:@"%c", CONTROL_OPEN_CHAR] intoString:nil];
    
    uint location = _scanner.scanLocation;
    
    [_scanner scanUpToString:[NSString stringWithFormat:@"%c", CONTROL_CLOSE_CHAR] intoString:nil];
    
    uint length = _scanner.scanLocation - location;
    
    [_scanner scanString:[NSString stringWithFormat:@"%c", CONTROL_CLOSE_CHAR] intoString:nil];
    
    NSString* string = [_attributedString.string substringWithRange:NSMakeRange(location, length)];
    
    if ([string isEqualToString:CONTROL_STRING_NEWLINE]) return ExerciseTextScannerControlTypeNewline;
    else return ExerciseTextScannerControlTypeUnknown;
}


- (void) scanNewlines {
    
    [_scanner scanCharactersFromSet:_newlineSet intoString:nil];
}


@end
