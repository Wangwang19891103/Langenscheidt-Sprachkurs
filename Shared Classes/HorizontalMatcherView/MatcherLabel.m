//
//  MatcherLabel.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "MatcherLabel.h"
#import "CGExtensions.h"
#import "UILabel+HTML.h"


#define FONT_NAME                           @"HelveticaNeue"
#define FONT_NAME_2                           @"HelveticaNeue-Bold"
#define FONT_SIZE                           14.0

#define GREEN                   [UIColor colorWithRed:51/255.0 green:172/255.0 blue:63/255.0 alpha:1.0]
#define RED                     [UIColor colorWithRed:213/255.0 green:0/255.0 blue:14/255.0 alpha:1.0]
#define BLUE                    [UIColor colorWithRed:0/255.0 green:151/255.0 blue:189/255.0 alpha:1.0]
#define WHITE                   [UIColor whiteColor]
#define ALMOST_WHITE            [UIColor colorWithWhite:0.97 alpha:1.0]
#define GRAY                    [UIColor colorWithWhite:0.85 alpha:1.0]
#define BLACK                   [UIColor blackColor]


#define BACKGROUND_COLOR_NORMAL     ALMOST_WHITE
#define BORDER_COLOR_NORMAL         BLUE
#define TEXT_COLOR_NORMAL           BLUE
#define FONT_NORMAL                 [UIFont fontWithName:FONT_NAME_2 size:FONT_SIZE]

#define BACKGROUND_COLOR_SELECTED     BLUE
#define BORDER_COLOR_SELECTED         nil
#define TEXT_COLOR_SELECTED           WHITE
#define FONT_SELECTED                 [UIFont fontWithName:FONT_NAME_2 size:FONT_SIZE]

#define BACKGROUND_COLOR_CORRECT     GREEN
#define BORDER_COLOR_CORRECT         nil
#define TEXT_COLOR_CORRECT           WHITE
#define FONT_CORRECT                 [UIFont fontWithName:FONT_NAME_2 size:FONT_SIZE]

#define BACKGROUND_COLOR_WRONG     RED
#define BORDER_COLOR_WRONG         nil
#define TEXT_COLOR_WRONG           WHITE
#define FONT_WRONG                 [UIFont fontWithName:FONT_NAME_2 size:FONT_SIZE]

#define BACKGROUND_COLOR_GHOST      GRAY
#define BORDER_COLOR_GHOST          nil
#define TEXT_COLOR_GHOST            BLACK
#define FONT_GHOST                  [UIFont fontWithName:FONT_NAME size:FONT_SIZE]

#define BACKGROUND_COLOR_IMMOVABLE      GRAY
#define BORDER_COLOR_IMMOVABLE          nil
#define TEXT_COLOR_IMMOVABLE            BLACK
#define FONT_IMMOVABLE                  [UIFont fontWithName:FONT_NAME size:FONT_SIZE]

#define LABEL_INSETS_LEFT        UIEdgeInsetsMake(18, 10, 18, 30)
#define LABEL_INSETS_RIGHT       UIEdgeInsetsMake(18, 30, 18, 10)

#define ANGLE           65.0  // degrees

#define BORDER_WIDTH            2.0
#define CORNER_RADIUS           5.0




@implementation MatcherLabel

@synthesize string;
@synthesize orientation;
@synthesize state;



- (id) init {
    
    self = [super init];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}


- (void) createView {
    
    _label = [[UILabel alloc] init];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.text = self.string;
    _label.textAlignment = (orientation == Right) ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    [_label parseHTML];
    
    [self addSubview:_label];
}


- (void) setState:(MatcherLabelState) p_state {

    state = p_state;

    [self _updateVisuals];
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


- (void) updateConstraints {

    UIEdgeInsets insets = (self.orientation == Left) ? LABEL_INSETS_LEFT : LABEL_INSETS_RIGHT;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[_label]-(right)-|" options:0 metrics:@{@"left" : @(insets.left), @"right" : @(insets.right)} views:NSDictionaryOfVariableBindings(_label)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[_label]-(bottom)-|" options:0 metrics:@{@"top" : @(insets.top), @"bottom" : @(insets.bottom)} views:NSDictionaryOfVariableBindings(_label)]];
    
    [super updateConstraints];
}


- (void) drawRect:(CGRect)rect {

//    rect = CGRectInset2(rect, UIEdgeInsetsMake(5,5,5,5));
    
    CGFloat borderWidth = BORDER_WIDTH;
    CGFloat cornerRadius = CORNER_RADIUS;
    CGFloat angleRadians = (ANGLE / 180.0) * M_PI;
    CGFloat indent = cosf(angleRadians) * rect.size.height * 0.5;

    CGPoint topLeft1 = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint topLeft2 = CGPointMake(rect.origin.x + borderWidth * 0.5, rect.origin.y + borderWidth * 0.5);
    CGPoint topLeft3 = CGPointMake(rect.origin.x, rect.origin.y);

    CGPoint topRight1 = CGPointMake(rect.origin.x + rect.size.width - indent, rect.origin.y);
    CGPoint topRight2 = CGPointMake(rect.origin.x + rect.size.width - borderWidth * 0.5, rect.origin.y + borderWidth * 0.5);
    CGPoint topRight3 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    
    CGPoint bottomLeft1 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    CGPoint bottomLeft2 = CGPointMake(rect.origin.x + borderWidth * 0.5, rect.origin.y + rect.size.height - borderWidth * 0.5);
    CGPoint bottomLeft3 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    
    CGPoint bottomRight1 = CGPointMake(rect.origin.x + rect.size.width - indent, rect.origin.y + rect.size.height);
    CGPoint bottomRight2 = CGPointMake(rect.origin.x + rect.size.width - borderWidth * 0.5, rect.origin.y + rect.size.height - borderWidth * 0.5);
    CGPoint bottomRight3 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    
    CGPoint middle1 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height * 0.5);
    CGPoint middle2 = CGPointMake(rect.origin.x + indent + borderWidth * 0.5, rect.origin.y + rect.size.height * 0.5);
    CGPoint middle3 = CGPointMake(rect.origin.x + indent, rect.origin.y + rect.size.height * 0.5);
    
    UIColor* backgroundColor = nil;
    UIColor* borderColor = nil;
    
    switch (self.state) {

        case Normal:
            backgroundColor = BACKGROUND_COLOR_NORMAL;
            borderColor = BORDER_COLOR_NORMAL;
            break;

        case Immovable:
            backgroundColor = BACKGROUND_COLOR_IMMOVABLE;
            borderColor = BORDER_COLOR_IMMOVABLE;
            break;

        case Ghost:
            backgroundColor = BACKGROUND_COLOR_GHOST;
            borderColor = BORDER_COLOR_GHOST;
            break;

        case Selected:
            backgroundColor = BACKGROUND_COLOR_SELECTED;
            borderColor = BORDER_COLOR_SELECTED;
            break;

        case Correct:
            backgroundColor = BACKGROUND_COLOR_CORRECT;
            borderColor = BORDER_COLOR_CORRECT;
            break;

        case Wrong:
            backgroundColor = BACKGROUND_COLOR_WRONG;
            borderColor = BORDER_COLOR_WRONG;
            break;

        default:
            break;
    }
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSaveGState(context);

    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    // fill background
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGMutablePathRef path = CGPathCreateMutable();
    
    if (self.orientation == Left) {
    
        CGPathMoveToPoint(path, NULL, middle1.x, middle1.y);
        CGPathAddLineToPoint(path, NULL, topRight1.x, topRight1.y);
        CGPathAddLineToPoint(path, NULL, topLeft1.x - cornerRadius, topLeft1.y);
        CGPathAddArc(path, NULL, topLeft1.x + cornerRadius, topLeft1.y + cornerRadius, cornerRadius, M_PI + M_PI_2, M_PI, YES);
        CGPathAddLineToPoint(path, NULL, bottomLeft1.x, bottomLeft1.y - cornerRadius);
        CGPathAddArc(path, NULL, bottomLeft1.x + cornerRadius, bottomLeft1.y - cornerRadius, cornerRadius, M_PI, M_PI_2, YES);
        CGPathAddLineToPoint(path, NULL, bottomRight1.x, bottomRight1.y);
        CGPathCloseSubpath(path);
    }
    else {

        if (borderColor) {

            CGPathMoveToPoint(path, NULL, middle2.x, middle2.y);
            CGPathAddLineToPoint(path, NULL, topLeft2.x, topLeft2.y);
            CGPathAddLineToPoint(path, NULL, topRight2.x - cornerRadius, topRight2.y);
            CGPathAddArc(path, NULL, topRight2.x - cornerRadius, topRight2.y + cornerRadius, cornerRadius, M_PI + M_PI_2, 0, NO);
            CGPathAddLineToPoint(path, NULL, bottomRight2.x, bottomRight2.y - cornerRadius);
            CGPathAddArc(path, NULL, bottomRight2.x - cornerRadius, bottomRight2.y - cornerRadius, cornerRadius, 0, M_PI_2, NO);
            CGPathAddLineToPoint(path, NULL, bottomLeft2.x, bottomLeft2.y);
            CGPathAddLineToPoint(path, NULL, middle2.x, middle2.y);
            CGPathCloseSubpath(path);
        }
        else {
            
            CGPathMoveToPoint(path, NULL, middle3.x, middle3.y);
            CGPathAddLineToPoint(path, NULL, topLeft3.x, topLeft3.y);
            CGPathAddLineToPoint(path, NULL, topRight3.x - cornerRadius, topRight3.y);
            CGPathAddArc(path, NULL, topRight3.x - cornerRadius, topRight3.y + cornerRadius, cornerRadius, M_PI + M_PI_2, 0, NO);
            CGPathAddLineToPoint(path, NULL, bottomRight3.x, bottomRight3.y - cornerRadius);
            CGPathAddArc(path, NULL, bottomRight3.x - cornerRadius, bottomRight3.y - cornerRadius, cornerRadius, 0, M_PI_2, NO);
            CGPathAddLineToPoint(path, NULL, bottomLeft3.x, bottomLeft3.y);
            CGPathAddLineToPoint(path, NULL, middle3.x, middle3.y);
            CGPathCloseSubpath(path);
        }
    }
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    
    if (borderColor) {
        
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetLineWidth(context, borderWidth);
        CGContextSetLineJoin(context, kCGLineJoinMiter);
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    
    CGContextRestoreGState(context);
    
}


- (void) _updateVisuals {
    
    UIColor* textColor = nil;
    UIFont* font = nil;
    
    switch (self.state) {

        case Normal:
            textColor = TEXT_COLOR_NORMAL;
            font = FONT_NORMAL;
            break;

        case Immovable:
            textColor = TEXT_COLOR_IMMOVABLE;
            font = FONT_IMMOVABLE;
            break;

        case Ghost:
            textColor = TEXT_COLOR_GHOST;
            font = FONT_GHOST;
            break;

        case Selected:
            textColor = TEXT_COLOR_SELECTED;
            font = FONT_SELECTED;
            break;

        case Correct:
            textColor = TEXT_COLOR_CORRECT;
            font = FONT_CORRECT;
            break;

        case Wrong:
            textColor = TEXT_COLOR_WRONG;
            font = FONT_WRONG;
            break;

        default:
            break;
    }
    
    _label.textColor = textColor;
    _label.font = font;
    
    [self setNeedsDisplay];
}


- (void) setNormalAppearance {
    
    self.state = Normal;
}


- (void) setGhostAppearance {
    
    self.state = Ghost;
}

@end
