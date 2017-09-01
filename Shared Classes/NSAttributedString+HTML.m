//
//  NSAttributedString+HTML.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "NSAttributedString+HTML.h"
#import "NSMutableAttributedString+HTML.h"


@implementation NSAttributedString (HTML)

- (NSAttributedString*) attributedStringWithParsedHTML {
    
    NSMutableAttributedString* mutableAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    
    [mutableAttributedString parseHTML];
    
    return mutableAttributedString;
}

@end
