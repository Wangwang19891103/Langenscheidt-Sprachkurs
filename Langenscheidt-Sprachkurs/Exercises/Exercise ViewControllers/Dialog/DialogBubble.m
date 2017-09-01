//
//  DialogBubble.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "DialogBubble.h"
#import "RoundedRectImage.h"
#import "CGExtensions.h"



#define BACKGROUND_COLOR     [UIColor colorWithRed:26/255.0 green:94/255.0 blue:120/255.0 alpha:1.0]
#define CORNER_RADIUS       5.0
#define INSETS      UIEdgeInsetsMake(CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS)

#define BACKGROUND_COLOR_BLUE       [UIColor colorWithRed:26/255.0 green:94/255.0 blue:120/255.0 alpha:1.0]
#define BACKGROUND_COLOR_ORANGE     [UIColor colorWithRed:220/255.0 green:118/255.0 blue:24/255.0 alpha:1.0]
#define BACKGROUND_COLOR_GREEN      [UIColor colorWithRed:94/255.0 green:122/255.0 blue:34/255.0 alpha:1.0]
#define BACKGROUND_COLOR_PURPLE     [UIColor colorWithRed:79/255.0 green:45/255.0 blue:89/255.0 alpha:1.0]
#define BACKGROUND_COLOR_BROWN      [UIColor colorWithRed:87/255.0 green:74/255.0 blue:57/255.0 alpha:1.0]
#define BACKGROUND_COLOR_RED        [UIColor colorWithRed:200/255.0 green:27/255.0 blue:76/255.0 alpha:1.0]
#define BACKGROUND_COLOR_GRAY       [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0]

#define TRIANGLE_POSITION_Y         20
#define TRIANGLE_WIDTH              8
#define TRIANGLE_ANGLE              60.0f

#define OPPOSITE_SIDE_MARGIN        20




NSInteger const kDialogBubbleNarratorColor = 100;


@implementation DialogBubble

@synthesize textLang1;
@synthesize textLang2;
@synthesize textFields = _textFields;
@synthesize color;
@synthesize speaker;
@synthesize side;
@synthesize rasterize;


- (id) init {
    
    self = [super init];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.clipsToBounds = NO;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
//    [self setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    self.rasterize = NO;
    
    return self;
}


- (void) setColor:(DialogBubbleColor)p_color {
    
    color = p_color;
    
    switch (self.color) {

        case Blue:
            _backgroundColor = BACKGROUND_COLOR_BLUE;
            break;

        case Orange:
            _backgroundColor = BACKGROUND_COLOR_ORANGE;
            break;

        case Green:
            _backgroundColor = BACKGROUND_COLOR_GREEN;
            break;

        case Purple:
            _backgroundColor = BACKGROUND_COLOR_PURPLE;
            break;

        case Brown:
            _backgroundColor = BACKGROUND_COLOR_BROWN;
            break;

        case Red:
            _backgroundColor = BACKGROUND_COLOR_RED;
            break;

        case Gray:
            _backgroundColor = BACKGROUND_COLOR_GRAY;
            break;

        default:
            break;
    }
}


- (void) setRasterize:(BOOL)p_rasterize {
    
    rasterize = p_rasterize;
    
    [self _processRasterize];
}


- (NSArray*) textFields {
    
    return _lang1TextView.textFields;
}


- (ExerciseTextView2*) textView {
    
    return _lang1TextView;
}


- (void) createView {
    
    UIEdgeInsets insets;
    
    if (_isNarratorBubble) {
        
        insets = UIEdgeInsetsMake(10, 15 + TRIANGLE_WIDTH, 10, 15 + TRIANGLE_WIDTH);
    }
    else if (self.side == 0) {
        
        insets = UIEdgeInsetsMake(10, 15 + TRIANGLE_WIDTH, 10, 15 + OPPOSITE_SIDE_MARGIN);
    }
    else {
        
        insets = UIEdgeInsetsMake(10, 15 + OPPOSITE_SIDE_MARGIN, 10, 15 + TRIANGLE_WIDTH);
    }
    
    self.layoutMargins = insets;

    
    UIColor* blackOrWhite = (_isNarratorBubble) ? [UIColor blackColor] : [UIColor whiteColor];
    
    
    if (!_isNarratorBubble) {

        _speakerLabel = [[UILabel alloc] init];
        _speakerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _speakerLabel.text = [self.speaker uppercaseString];
        _speakerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0];
        _speakerLabel.textColor = [UIColor whiteColor];
        _speakerLabel.alpha = 0.75;
        [_speakerLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_speakerLabel];
    }
    
    _lang1TextView = [[ExerciseTextView2 alloc] init];
    [self addSubview:_lang1TextView];
    _lang1TextView.string = self.textLang1;
    _lang1TextView.fontName = @"HelveticaNeue";
    _lang1TextView.fontSize = 17.0;
    _lang1TextView.textColor = blackOrWhite;

    _lang1TextView.textFieldTextColorActive = blackOrWhite;
    _lang1TextView.textFieldTextColorFinished = blackOrWhite;
    _lang1TextView.textFieldTextColorCorrect = blackOrWhite;
    _lang1TextView.textFieldTextColorWrong = blackOrWhite;

    _lang1TextView.textFieldBackgroundColorActive = [UIColor clearColor];
    _lang1TextView.textFieldBackgroundColorFinished = [UIColor clearColor];
    _lang1TextView.textFieldBackgroundColorCorrect = [UIColor clearColor];
    _lang1TextView.textFieldBackgroundColorWrong = [UIColor clearColor];
    
    _lang1TextView.textFieldBorderColorActive = blackOrWhite;
    _lang1TextView.textFieldBorderColorFinished = blackOrWhite;
    _lang1TextView.textFieldBorderColorCorrect = blackOrWhite;
    _lang1TextView.textFieldBorderColorWrong = blackOrWhite;

    _lang1TextView.layoutMargins = UIEdgeInsetsZero;
    [_lang1TextView setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisVertical];
    _lang1TextView.accessibilityIdentifier = self.textLang1;
    _lang1TextView.textFieldsCanBeTapped = NO;
    [_lang1TextView createView];
    
    _separatorView = [[UIView alloc] init];
    _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    _separatorView.backgroundColor = blackOrWhite;
    _separatorView.alpha = 0.5;
    [self addSubview:_separatorView];
    
    _lang2Label = [[UILabel alloc] init];
    _lang2Label.translatesAutoresizingMaskIntoConstraints = NO;
    _lang2Label.numberOfLines = 0;
    _lang2Label.text = self.textLang2;
    _lang2Label.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:14.0];
    _lang2Label.textColor = blackOrWhite;
    _lang2Label.alpha = 0.75;
    [self addSubview:_lang2Label];
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


- (void) layoutSubviews {

    [super layoutSubviews];

    // !!!! this is deactivated (layoutSubviews outside of bracket)
    
    if (!_finishedLayouting) {

        NSLog(@"DialogBubble - layoutSubviews  (%@) (label2: %@)", NSStringFromCGRect(self.frame), NSStringFromCGRect(_lang2Label.frame));

        
        _finishedLayouting = YES;
    }


}


- (void) updateConstraints {

    NSLog(@"DialogBubble - updateConstraints  (%@)", NSStringFromCGRect(self.frame));

    [self _arrangeSubviews];
    
    [super updateConstraints];
}



#pragma mark - Rasterize

- (void) _processRasterize {
    
    self.layer.shouldRasterize = self.rasterize;
}



#pragma mark - Arrange Subviews


- (void) _arrangeSubviews {

    NSLog(@"DialogBubble - arrangeSubviews  (%@)", NSStringFromCGRect(self.frame));

    if (!_isNarratorBubble) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_speakerLabel]-(==right@700,>=right@1000)-|" options:0 metrics:@{@"right" : @(self.layoutMargins.right)} views:NSDictionaryOfVariableBindings(_speakerLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_speakerLabel]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_speakerLabel)]];
    }
    
    
    if (_isNarratorBubble) {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_lang1TextView]-|" options:0 metrics:@{@"right" : @(self.layoutMargins.right)} views:NSDictionaryOfVariableBindings(_lang1TextView)]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_lang1TextView]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_lang1TextView)]];
    }
    else {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_lang1TextView]-(>=right@1000,==right@750)-|" options:0 metrics:@{@"right" : @(self.layoutMargins.right)} views:NSDictionaryOfVariableBindings(_lang1TextView)]];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_speakerLabel]-6-[_lang1TextView]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_speakerLabel, _lang1TextView)]];
    }

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_separatorView]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_separatorView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lang1TextView]-8-[_separatorView(1)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_lang1TextView, _separatorView)]];

//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lang1TextView]-8-[_separatorView(1)]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_lang1TextView, _separatorView)]];

    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_lang2Label]-(==right@700,>=right@1000)-|" options:0 metrics:@{@"right" : @(self.layoutMargins.right)} views:NSDictionaryOfVariableBindings(_lang2Label, _lang1TextView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_separatorView]-8-[_lang2Label]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_separatorView, _lang2Label)]];

}



#pragma mark - Draw Rect

- (void) drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    
    // draw rounded rect
    
    UIImage* image = [[RoundedRectImage roundedRectImageWithColor:_backgroundColor cornerRadius:CORNER_RADIUS borderWidth:0 borderColor:nil] resizableImageWithCapInsets:INSETS resizingMode:UIImageResizingModeStretch];
    
    CGRect roundedRect;
    
    if (_isNarratorBubble) {
        
        roundedRect = CGRectInset2(rect, UIEdgeInsetsMake(0, TRIANGLE_WIDTH, 0, TRIANGLE_WIDTH));
    }
    else if (self.side == 0) {
        
        roundedRect = CGRectInset2(rect, UIEdgeInsetsMake(0, TRIANGLE_WIDTH, 0, OPPOSITE_SIDE_MARGIN));
    }
    else {
        
        roundedRect = CGRectInset2(rect, UIEdgeInsetsMake(0, OPPOSITE_SIDE_MARGIN, 0, TRIANGLE_WIDTH));
    }

    
    [image drawInRect:roundedRect];
    
    
    // draw triangle
    if (!_isNarratorBubble) {
    
        CGFloat triangleAngle = (TRIANGLE_ANGLE / 180.0) * M_PI;
        CGFloat angle2 = triangleAngle * 0.5;
        
        // point 1
        
        CGPoint point1 = CGPointMake(TRIANGLE_WIDTH, TRIANGLE_POSITION_Y);
        
        // point 2

        CGFloat x2 = 0;
        CGFloat y2 = TRIANGLE_POSITION_Y + sinf(angle2) * TRIANGLE_WIDTH;
        
        CGPoint point2 = CGPointMake(x2, y2);
        
        // point 3
        
        CGFloat x3 = TRIANGLE_WIDTH;
        CGFloat y3 = TRIANGLE_POSITION_Y + sinf(triangleAngle) * TRIANGLE_WIDTH;

        CGPoint point3 = CGPointMake(x3, y3);

        CGAffineTransform transform = CGAffineTransformIdentity;
        
        if (self.side == 1) {
        
            CGAffineTransform translation = CGAffineTransformMakeTranslation(rect.size.width, 0);
            CGAffineTransform scale = CGAffineTransformMakeScale(-1, 1);
            transform = CGAffineTransformConcat(scale, translation);
        }
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, &transform, point1.x, point1.y);
        CGPathAddLineToPoint(path, &transform, point2.x, point2.y);
        CGPathAddLineToPoint(path, &transform, point3.x, point3.y);
//        CGPathAddLineToPoint(path, NULL, point1.x, point1.y);
        CGPathCloseSubpath(path);
        
        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, _backgroundColor.CGColor);
        
        CGContextFillPath(context);
    }
}




#pragma mark - Description

- (NSString*) description {
    
    return [_lang1TextView description];
}






@end













