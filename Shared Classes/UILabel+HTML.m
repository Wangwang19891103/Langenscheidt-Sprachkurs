//
//  UILabel+HTML.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "UILabel+HTML.h"
#import "NSAttributedString+HTML.h"


@implementation UILabel (HTML)

- (void) parseHTML {
    
    self.attributedText = [self.attributedText attributedStringWithParsedHTML];
}

@end
