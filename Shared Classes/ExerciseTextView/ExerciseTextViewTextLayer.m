//
//  ExerciseTextViewTextLayer.m
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 12.12.13.
//  Copyright (c) 2013 mobilinga. All rights reserved.
//

#import "ExerciseTextViewTextLayer.h"
@import UIKit;


@implementation ExerciseTextViewTextLayer

@synthesize attributedString;
@synthesize isWhitespace;
@synthesize isNewline;


- (id) init {
    
    self = [super init];
    
    self.needsDisplayOnBoundsChange = true;
//    self.backgroundColor = BLACK_COLOR.CGColor;
    self.anchorPoint = CGPointMake(0, 0);
    self.contentsScale = [[UIScreen mainScreen] scale];
//    self.backgroundColor = CLEAR_COLOR.CGColor;
//    self.opaque = false;
    
    return self;
}


- (void) setAttributedString:(NSAttributedString *)p_attributedString {
    
    attributedString = p_attributedString;
    
    CGRect textRect = [self.attributedString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];

    self.bounds = CGRectMake(ceil(textRect.origin.x),
                             ceil(textRect.origin.y),
                             ceil(textRect.size.width),
                             ceil(textRect.size.height));
}


- (void) drawInContext:(CGContextRef)ctx {
    
    UIGraphicsPushContext(ctx);

//    CGContextClearRect(ctx, self.bounds);
//    CGContextSetFillColorWithColor(ctx, CLEAR_COLOR.CGColor);
//    CGContextFillRect(ctx, self.bounds);
    
    
    [self.attributedString drawInRect:self.bounds];
    
    UIGraphicsPopContext();
}


- (NSString*) description {
    
    return [NSString stringWithFormat:@"ExerciseTextViewTextLayer (string='%@', whiteSpace=%@, newLine=%@)", attributedString.string, isWhitespace ? @"yes" : @"no", isNewline ? @"yes" : @"no"];
}


@end
