//
//  NSAttributedString+(HTML).m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "NSMutableAttributedString+HTML.h"

#define TAG_OPEN        @"<"
#define TAG_CLOSE       @">"
#define TAG_SLASH       @"/"
#define TAG_NAME_ITALIC     @"i"
#define TAG_NAME_ITALIC2    @"k"
#define TAG_NAME_BOLD       @"b"
#define DELETION_MARK_STRING   @"~"

/*  !!!!!!!!!!!!!!!!!!!!!!
*
*   Wont handle nested tags
*
*
*/



@implementation NSMutableAttributedString (HTML)

- (void) parseHTML {
    
    [self parseHTMLWithCustomAttributesBlock:nil];
}


- (void) parseHTMLWithCustomAttributesBlock:(NSDictionary* (^)(NSString* tagName)) customAttributesBlock {
    
//    NSLog(@"string to parse: %@", self.string);
    
    NSScanner* scanner = [[NSScanner alloc] initWithString:self.string];
    scanner.charactersToBeSkipped = nil;  // this is important (its whitespacenewline by default) because otherwise scanning a second open tag after a previous tag compound will not scan the range properly
    
    while (![scanner isAtEnd]) {
        
        // find next HTML tag
        
//        NSLog(@"rest string (location: %ld): %@", scanner.scanLocation, [scanner.string substringFromIndex:scanner.scanLocation]);
        
        NSString* dummy = [self.string substringFromIndex:scanner.scanLocation];
        
        [scanner scanUpToString:TAG_OPEN intoString:nil];
        
//        NSLog(@"scan loc after scanning up to open tag: %ld (dummy: '%@')", scanner.scanLocation, dummy);
        
        if (![scanner isAtEnd]) {

            NSRange rangeOfOpeningTag = NSMakeRange(scanner.scanLocation, 0);

            [scanner scanString:TAG_OPEN intoString:nil];
            
            NSString* tagName = nil;
            [scanner scanUpToString:TAG_CLOSE intoString:&tagName];
            
            if (![scanner isAtEnd]) {
                
                [scanner scanString:TAG_CLOSE intoString:nil];
                
                rangeOfOpeningTag.length = scanner.scanLocation - rangeOfOpeningTag.location;
                [self _handleTag:tagName scanner:scanner range:rangeOfOpeningTag customAttributesBlock:customAttributesBlock];
                
//                NSLog(@"MARKED STRING: %@", self.string);

            }
        }
    }
    
    
    [self _deleteMarkedRanges];
    
//    NSLog(@"new string: %@", self.string);
}


- (void) _handleTag:(NSString*) tagName scanner:(NSScanner*) scanner range:(NSRange) rangeOfOpeningTag customAttributesBlock:(NSDictionary* (^)(NSString*)) customAttributesBlock {
    
    NSString* tagContents = nil;
    
    [scanner scanUpToString:TAG_OPEN intoString:&tagContents];
    
    if (![scanner isAtEnd]) {

        NSRange rangeOfClosingTag = NSMakeRange(scanner.scanLocation, 0);

        [scanner scanString:TAG_OPEN intoString:nil];
        
        NSString* tagName2 = nil;
        
        [scanner scanUpToString:TAG_CLOSE intoString:&tagName2];
        
        if (![scanner isAtEnd]) {
            
            [scanner scanString:TAG_CLOSE intoString:nil];
            
            tagName2 = [tagName2 stringByReplacingOccurrencesOfString:TAG_SLASH withString:@""];
            rangeOfClosingTag.length = scanner.scanLocation - rangeOfClosingTag.location;
            
            if ([tagName2 isEqualToString:tagName]) {
                
                [self _handleTagContents:tagContents withTagName:tagName openingRange:rangeOfOpeningTag closingRange:rangeOfClosingTag customAttributesBlock:customAttributesBlock];
            }
        }
        
    }
}


- (void) _handleTagContents:(NSString*) tagContents withTagName:(NSString*) tagName openingRange:(NSRange) openingRange closingRange:(NSRange) closingRange customAttributesBlock:(NSDictionary* (^)(NSString*)) customAttributesBlock {
    
//    NSString* openingString = [self.string substringWithRange:openingRange];
//    NSString* closingString = [self.string substringWithRange:closingRange];
    
    NSInteger contentRangeBeginLocation = openingRange.location + openingRange.length;
    NSInteger contentRangeEndLocation = closingRange.location;
    NSRange contentRange = NSMakeRange(contentRangeBeginLocation, contentRangeEndLocation - contentRangeBeginLocation);
    
    
    NSDictionary* customTextAttributes = ({
    
        NSDictionary* dict = nil;;
        
        if (customAttributesBlock) {
            
            dict = customAttributesBlock(tagName);
        }
        
        dict;
    });
    
    if (customTextAttributes) {
        
        [self setAttributes:customTextAttributes range:contentRange];
    }
    else {
        
        NSDictionary* attributes = [self attributesAtIndex:contentRange.location effectiveRange:NULL];
        UIFont* font = attributes[NSFontAttributeName];
        UIFontDescriptor* descriptor = font.fontDescriptor;
        UIFontDescriptorSymbolicTraits traits = descriptor.symbolicTraits;
        
        if ([tagName isEqualToString:TAG_NAME_ITALIC]
            || [tagName isEqualToString:TAG_NAME_ITALIC2]) {
            
            traits |= UIFontDescriptorTraitItalic;
        }
        else if ([tagName isEqualToString:TAG_NAME_BOLD]) {
            
            traits |= UIFontDescriptorTraitBold;
        }
        
        UIFontDescriptor* newDescriptor = [descriptor fontDescriptorWithSymbolicTraits:traits];
        UIFont* newFont = [UIFont fontWithDescriptor:newDescriptor size:0];
        NSMutableDictionary* newTextAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        newTextAttributes[NSFontAttributeName] = newFont;
        
        [self setAttributes:newTextAttributes range:contentRange];
    }
    
    
//    NSString* contentString = [self.string substringWithRange:contentRange];
    
    
    
    // remove tags in string
    
    [self _markRangeForDeletion:openingRange];
    [self _markRangeForDeletion:closingRange];
}


- (void) _markRangeForDeletion:(NSRange) range {
    
    NSMutableString* markString = [[NSMutableString alloc] init];
    
    for (uint i = 0; i < range.length; ++i) {
        
        [markString appendString:DELETION_MARK_STRING];
    }

    NSString* replacedString = [self.string substringWithRange:range];
//    NSLog(@"replacing string '%@' with marker", replacedString);
    
    [self.mutableString replaceCharactersInRange:range withString:markString];
}


- (void) _deleteMarkedRanges {
    
    [self.mutableString replaceOccurrencesOfString:DELETION_MARK_STRING withString:@"" options:0 range:NSMakeRange(0, self.mutableString.length)];
}

@end
