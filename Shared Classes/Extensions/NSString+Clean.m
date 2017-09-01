//
//  NSString+Clean.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "NSString+Clean.h"

@implementation NSString (Clean)

- (NSString*) cleanString {
    
    NSString* cleanedString = [self copy];

    cleanedString = [self _removeLeadingWhitespaces:cleanedString];
    cleanedString = [self _removeTrailingWhitespaces:cleanedString];
    
    return cleanedString;
}


- (NSString*) _removeTrailingWhitespaces:(NSString*) string {
    
    NSInteger index = string.length - 1;
    
    while (index >= 0) {
        
        unichar c = [string characterAtIndex:index];
    
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:c]) {
            
            --index;
        }
        else {
            
            break;
        }
    }
    
    return [string substringToIndex:index + 1];
}


- (NSString*) _removeLeadingWhitespaces:(NSString*) string {
    
    NSInteger index = 0; //string.length - 1;
    
    while (index < string.length - 1) {
        
        unichar c = [string characterAtIndex:index];
        
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:c]) {
            
            ++index;
        }
        else {
            
            break;
        }
    }
    
    return [string substringFromIndex:index];
}

@end
