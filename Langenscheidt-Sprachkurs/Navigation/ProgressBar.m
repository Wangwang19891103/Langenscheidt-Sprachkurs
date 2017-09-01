//
//  ProgressBar.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "ProgressBar.h"


@implementation ProgressBar

@synthesize percentage;
@synthesize barForegroundColor;
@synthesize barBackgroundColor;


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}


- (id) init {
    
    self = [super init];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}


- (void) awakeFromNib {
    
    [super awakeFromNib];
    
    if (!self.backgroundColor) {
        
        self.backgroundColor = [UIColor clearColor];
    }

    if (!self.barForegroundColor) {
        
        self.barForegroundColor = [UIColor clearColor];
    }

    if (!self.barBackgroundColor) {
        
        self.barBackgroundColor = [UIColor clearColor];
    }

}


- (void) setPercentage:(CGFloat)p_percentage {
    
    percentage = p_percentage;
    
    [self setNeedsDisplay];
}



#pragma mark - View, Layout, Constraints

+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}



#pragma mark - Rendering

- (void) drawRect:(CGRect)rect {
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;

    CGFloat percentageWidth = width * self.percentage;
    CGFloat lineWidth = height;
    CGFloat capWidth = lineWidth * 0.5;
    CGPoint startPosition = CGPointMake(0 + capWidth, lineWidth * 0.5);
    CGPoint endPosition = CGPointMake(percentageWidth - capWidth, lineWidth * 0.5);
    CGPoint endPosition2 = CGPointMake(width - capWidth, lineWidth * 0.5);
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);

    
    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
//    // draw background bar
    CGContextSetStrokeColorWithColor(context, self.barBackgroundColor.CGColor);
    CGContextMoveToPoint(context, startPosition.x, startPosition.y);
    CGContextAddLineToPoint(context, endPosition2.x, endPosition2.y);
    CGContextStrokePath(context);
    
//    // draw foreground bar
    if (self.percentage > 0) {
        
        CGContextSetStrokeColorWithColor(context, self.barForegroundColor.CGColor);
        CGContextMoveToPoint(context, startPosition.x, startPosition.y);
        CGContextAddLineToPoint(context, endPosition.x, endPosition.y);
        CGContextStrokePath(context);
    }
    
    CGContextRestoreGState(context);
}



#pragma mark - Interface Builder

- (void) prepareForInterfaceBuilder {
    
    [self awakeFromNib];
}


@end
