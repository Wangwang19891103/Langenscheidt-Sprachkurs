//
//  NSAttributedString+Extensions.m
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 23.09.13.
//  Copyright (c) 2013 Stefan Ueter. All rights reserved.
//

#import "NSAttributedString+Extensions.h"
@import UIKit;


@implementation NSAttributedString (Extensions)



- (CGPoint) positionForSubstringInRange:(NSRange) range contrainedToWidth:(float) width {
    
//    NSLog(@"########### substring: \"%@\" ############", [self.string substringWithRange:NSMakeRange(range.location - 2, range.length + 4)]);
    // ausgabe crasht manchmal wenn range ganz am ende
    
    NSRange range2 = NSMakeRange(0, 1);
    NSDictionary* textAttributes = [self attributesAtIndex:0 effectiveRange:&range2];
    
    float heightPerLine = [@"a" sizeWithAttributes:textAttributes].height;
    float lineSpacing = [textAttributes[NSParagraphStyleAttributeName] lineSpacing];
//    heightPerLine += lineSpacing;
    
    
    NSString* stringUpToSubstring = nil;
    CGRect textRect;
    
    
    
    // case 1: substring is in first line
    
    stringUpToSubstring = [self.string substringWithRange:NSMakeRange(0, range.location + range.length)];  // including the substring
    textRect = [stringUpToSubstring boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                              attributes:textAttributes
                                                 context:nil];
    
    NSLog(@"stringUpToSubstring: \"%@\"", stringUpToSubstring);
    
//    float lineOfSubstringBegin = textRect.size.height / heightPerLine; assert(lineOfSubstringBegin == (uint)lineOfSubstringBegin);
    float lineOfSubstringBegin = [self numberOfLinesForHeight:textRect.size.height
                                              usingLineHeight:heightPerLine
                                                  lineSpacing:lineSpacing];
    
    NSLog(@"range: %@, line: %f, textRect: %@", NSStringFromRange(range), lineOfSubstringBegin, NSStringFromCGRect(textRect));
    
    if (lineOfSubstringBegin == 1) {  // substring begins in first line
        
        NSLog(@"first line");

        stringUpToSubstring = [self.string substringWithRange:NSMakeRange(0, range.location)];  // EXCLUDING the substring
        textRect = [stringUpToSubstring boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                  attributes:textAttributes
                                                     context:nil];

        
        NSLog(@"posX: %f", floor(textRect.size.width));

        return CGPointMake(floor(textRect.size.width), 0);
    }
    
    // case 2: substring is not in first line
    
    // find location of first char to be rendered in lineOfSubstringBegin
    
//    NSLog(@"---------- BINARY SEARCH ------");

    
    uint indexOfFirstCharInLineOfSubstringBegin = 0;
    {
        int locationLeft = 0;
        int locationRight = range.location;
//        uint middle = 0;
        NSString* substring = nil;
        CGRect textRect;
        float lines;
        uint count = 0;

//        while (locationLeft <= locationRight) {
        while (locationRight >= 0) {
        
//            middle = (locationLeft + locationRight) / 2;
//            substring = [self.string substringWithRange:NSMakeRange(0, middle)];
            substring = [self.string substringWithRange:NSMakeRange(0, locationRight)];
            textRect = [substring boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:textAttributes
                                               context:nil];
            lines = [self numberOfLinesForHeight:textRect.size.height
                                 usingLineHeight:heightPerLine
                                     lineSpacing:lineSpacing];
            
//            NSLog(@"(%d) LEFT: %d, RIGHT: %d, MIDDLE: %d, lines: %0.0f", count, locationLeft, locationRight, middle, lines);
            NSLog(@"(%d) RIGHT: %d, lines: %0.0f", count, locationRight, lines);
            
            NSLog(@"substring: \"%@\"", substring);
            
            if (lines < lineOfSubstringBegin) {
                
//                locationLeft = middle + 1;
                
                // go forward to next word begin

//                unichar c;

//                while (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:(c = [[self.string substringWithRange:NSMakeRange(locationRight, 1)] characterAtIndex:0])]) {
//                    
//                    
//                    NSLog(@"++locationRight: %d, \"%C\"", locationRight, c);
//                    ++locationRight;
//                }
//
//                NSLog(@"new locationRight: %d, \"%C\"", locationRight, c);
//
//                while ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:(c = [[self.string substringWithRange:NSMakeRange(locationRight, 1)] characterAtIndex:0])]) {
//                    
//                    NSLog(@"++locationRight: %d, \"%C\"", locationRight, c);
//                    ++locationRight;
//                }
//
//                NSLog(@"new locationRight: %d, \"%C\"", locationRight, c);
//
//                locationRight += 1;
//                
                break;
            }
            else if (lines == lineOfSubstringBegin) {
                
                // go back to closest word begin
                
                // go back white space chars
                
                --locationRight;
                
                unichar c;
                
                while ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:(c = [[self.string substringWithRange:NSMakeRange(locationRight, 1)] characterAtIndex:0])]) {
                    

                    NSLog(@"--locationRight: %d, \"%C\"", locationRight, c);
                    --locationRight;
                }

                NSLog(@"new locationRight: %d, \"%C\"", locationRight, c);

                while (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:(c = [[self.string substringWithRange:NSMakeRange(locationRight, 1)] characterAtIndex:0])]) {
                    

                    NSLog(@"--locationRight: %d, \"%C\"", locationRight, c);
                    --locationRight;
                }

                NSLog(@"new locationRight: %d, \"%C\"", locationRight, c);

                locationRight += 1;

            }
        
            ++count;
        }
        
        NSLog(@"lines = %0.0f, lineOfSubstring = %0.0f", lines, lineOfSubstringBegin);

        indexOfFirstCharInLineOfSubstringBegin = locationRight;
        
//        if (lines == lineOfSubstringBegin) {
//            
//            middle -= 1;  //TODO: possible adjustment
//        }
        
//        // go back to closest word break
//        {
//            uint index = middle;
//            
//            while (![[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[[self.string substringWithRange:NSMakeRange(index, 1)] characterAtIndex:0]]) {
//                   
//                --index;
//            }
//            
//            indexOfFirstCharInLineOfSubstringBegin = index + 1;
//        }
        
    }
    
    NSString* substringInLineOfSearchedSubstringBegin = [self.string substringWithRange:NSMakeRange(indexOfFirstCharInLineOfSubstringBegin, range.location - indexOfFirstCharInLineOfSubstringBegin)];
    
    NSLog(@"substring in line: \"%@\" (Range: %d, %d)", substringInLineOfSearchedSubstringBegin, indexOfFirstCharInLineOfSubstringBegin, range.location - indexOfFirstCharInLineOfSubstringBegin);
    
    textRect = [substringInLineOfSearchedSubstringBegin boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                  attributes:textAttributes
                                                                     context:nil];
    
    NSLog(@"posX: %f", floor(textRect.size.width));
    
    return CGPointMake(floor(textRect.size.width), (lineOfSubstringBegin - 1) * (heightPerLine + lineSpacing));
    
}


- (NSArray*) componentsSeperatedByString:(NSString*) separatorString {
    
    assert(separatorString);
    
    NSMutableArray* components = [NSMutableArray array];
    
    uint currentIndex = 0;
    uint beginIndex = 0;
    
    void(^addCurrentComponent)(uint, uint) = ^(uint from, uint to) {
        
        NSAttributedString* attributedSubstring = [self attributedSubstringFromRange:NSMakeRange(from, to - from + 1)];
        [components addObject:attributedSubstring];
    };
    
    while (currentIndex < self.string.length) {
        
        if ([[self.string substringWithRange:NSMakeRange(currentIndex, 1)] isEqualToString:separatorString]) {
            
            addCurrentComponent(beginIndex, currentIndex - 1);
            beginIndex = currentIndex + 1;
        }
        
        ++currentIndex;
    }
    
    addCurrentComponent(beginIndex, currentIndex - 1);
    
    return components;
}



#pragma mark - Utility

- (uint) numberOfLinesForHeight:(float) height usingLineHeight:(float) lineHeight lineSpacing:(float) lineSpacing {
    
    if (height == lineHeight) return 1;
    
    else {
        
        float lines = (height - lineHeight) / (lineHeight + lineSpacing) + 1;
        
//        assert(lines == (uint)lines);
        
        return lines;
    }
}


- (float) heightForNumberOfLines:(uint) lines usingLineHeight:(float) lineHeight lineSpacing:(float) lineSpacing {
    
    if (lines == 1) return lineHeight;
    
    else {
        
        return lineHeight + (lines - 1) * (lineHeight + lineSpacing);
    }
}


@end
