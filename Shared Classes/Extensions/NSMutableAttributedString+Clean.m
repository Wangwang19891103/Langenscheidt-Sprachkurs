//
//  NSString+Clean.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "NSMutableAttributedString+Clean.h"

@implementation NSMutableAttributedString (Clean)

- (NSMutableAttributedString*) cleanAttributedString {
    
    NSMutableAttributedString* newAttributedString = [self copy];
    
    newAttributedString = [self _removeLeadingWhitespaces:newAttributedString];
    newAttributedString = [self _removeTrailingWhitespaces:newAttributedString];
    
    return newAttributedString;
}


- (NSMutableAttributedString*) _removeTrailingWhitespaces:(NSAttributedString*) attributedString {
    
    NSInteger index = attributedString.string.length - 1;
    
    while (index >= 0) {
        
        unichar c = [attributedString.string characterAtIndex:index];
    
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:c]) {
            
            --index;
        }
        else {
            
            break;
        }
    }
    
    NSAttributedString* newAttributedString = [attributedString attributedSubstringFromRange:NSMakeRange(0, index + 1)];
    
    return [newAttributedString mutableCopy];
}


- (NSMutableAttributedString*) _removeLeadingWhitespaces:(NSAttributedString*) attributedString {
    
    NSInteger index = 0; //string.length - 1;
    
    while (index < attributedString.string.length - 1) {
        
        unichar c = [attributedString.string characterAtIndex:index];
        
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:c]) {
            
            ++index;
        }
        else {
            
            break;
        }
    }
    
//    return [string substringFromIndex:index];
    
    NSAttributedString* newAttributedString = [attributedString attributedSubstringFromRange:NSMakeRange(index, attributedString.string.length - index)];
    
    return [newAttributedString mutableCopy];

}

@end
