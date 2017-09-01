//
//  NSAttributedString+Extensions.h
//  StueStandardLibrary
//
//  Created by Stefan Ueter on 23.09.13.
//  Copyright (c) 2013 Stefan Ueter. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@interface NSAttributedString (Extensions)


- (CGPoint) positionForSubstringInRange:(NSRange) range contrainedToWidth:(float) width;


- (NSArray*) componentsSeperatedByString:(NSString*) separatorString;


@end
