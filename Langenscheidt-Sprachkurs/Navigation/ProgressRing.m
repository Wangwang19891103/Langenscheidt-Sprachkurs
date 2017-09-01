//
//  ProgressRing.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "ProgressRing.h"
#import "CGExtensions.h"


@implementation ProgressRing

@synthesize percentage;
@synthesize lineWidth;
@synthesize ringForegroundColor;
@synthesize ringBackgroundColor;
@synthesize fontName;
@synthesize fontSize;
@synthesize smallFontSize;
@synthesize textColor;



#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}


- (void) awakeFromNib {
    
    [super awakeFromNib];
    
    if (!self.backgroundColor) {
        
        self.backgroundColor = [UIColor clearColor];
    }
    
    if (!self.ringForegroundColor) {
        
        self.ringForegroundColor = [UIColor clearColor];
    }
    
    if (!self.ringBackgroundColor) {
        
        self.ringBackgroundColor = [UIColor clearColor];
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
    
    CGPoint centerPoint = CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5);
    CGPoint startPoint = CGPointMake(rect.size.width * 0.5, 0);
    CGFloat radius = (rect.size.width - lineWidth) * 0.5;
    CGFloat startAngle = 3 * M_PI_2;
    CGFloat foregroundAngleDistance = fmod((M_PI * 2 * self.percentage * 0.99999), (M_PI * 2));
    CGFloat foregroundEndAngle = startAngle + foregroundAngleDistance;
    CGFloat backgroundEndAngle = startAngle + M_PI * 2 * 0.99999;
    UIFont* font = [UIFont fontWithName:self.fontName size:self.fontSize];
    UIFont* fontSmall = [UIFont fontWithName:self.fontName size:self.smallFontSize];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetLineCap(context, kCGLineCapButt);
    
    
    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    // draw background ring
    {
        CGContextSetStrokeColorWithColor(context, self.ringBackgroundColor.CGColor);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
        CGPathAddArc(path, NULL, centerPoint.x, centerPoint.y, radius, startAngle, backgroundEndAngle, NO);
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    // draw foreground ring
    {
        if (percentage != 0.0f) {

            CGContextSetStrokeColorWithColor(context, self.ringForegroundColor.CGColor);
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
            CGPathAddArc(path, NULL, centerPoint.x, centerPoint.y, radius, startAngle, foregroundEndAngle, NO);
            CGContextAddPath(context, path);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
    
    // draw text
    {
        NSInteger number = ceil(self.percentage * 100);
        NSString* numberString = [NSString stringWithFormat:@"%ld", number];
        NSString* percentString = @"%";
        NSAttributedString* attributedNumberString = [[NSAttributedString alloc] initWithString:numberString attributes:@{
                                                                                                                          NSFontAttributeName : font,
                                                                                                                          NSForegroundColorAttributeName : self.textColor
                                                                                                                          }];
        NSAttributedString* attributedPercentString = [[NSAttributedString alloc] initWithString:percentString attributes:@{
                                                                                                                          NSFontAttributeName : fontSmall,
                                                                                                                          NSForegroundColorAttributeName : self.textColor
                                                                                                                          }];
        NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:attributedNumberString];
        [attributedString appendAttributedString:attributedPercentString];
        CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGRect textDrawingRect = CGRectCenterOverPoint(textRect, centerPoint);
        [attributedString drawInRect:textDrawingRect];
    }
    
    CGContextRestoreGState(context);
}



#pragma mark - Interface Builder

- (void) prepareForInterfaceBuilder {
    
    [self awakeFromNib];
}


@end
