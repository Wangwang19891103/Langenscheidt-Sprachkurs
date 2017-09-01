//
//  SnakeUnderlayItem.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "SnakeUnderlayItem.h"
#import "RoundedRectImage.h"
#import "CGExtensions.h"


@implementation SnakeUnderlayItem

- (id) init {
    
    self = [super init];
    
//    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    return self;
}


- (void) drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    
    UIImage* image = [[RoundedRectImage roundedRectImageWithColor:self.color cornerRadius:self.cornerRadius borderWidth:0 borderColor:nil] resizableImageWithCapInsets:UIEdgeInsetsMake(self.cornerRadius,self.cornerRadius,self.cornerRadius,self.cornerRadius) resizingMode:UIImageResizingModeStretch];

    [image drawInRect:rect];
    
    
    
    CGContextRestoreGState(context);
}


@end
