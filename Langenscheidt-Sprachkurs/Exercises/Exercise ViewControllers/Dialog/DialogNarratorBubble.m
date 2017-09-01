//
//  DialogBubble.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "DialogNarratorBubble.h"
#import "RoundedRectImage.h"
#import "CGExtensions.h"



#define BACKGROUND_COLOR     [UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0]
#define CORNER_RADIUS       5.0
#define INSETS      UIEdgeInsetsMake(CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS, CORNER_RADIUS)



@implementation DialogNarratorBubble

@synthesize textLang1;
@synthesize textLang2;
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




- (void) setRasterize:(BOOL)p_rasterize {
    
    rasterize = p_rasterize;
    
    [self _processRasterize];
}


- (void) createView {
    
    UIEdgeInsets insets;
    insets = UIEdgeInsetsMake(10, 23, 10, 23);
    self.layoutMargins = insets;

    
    
    _lang1Label = [[UILabel alloc] init];
    _lang1Label.translatesAutoresizingMaskIntoConstraints = NO;
    _lang1Label.numberOfLines = 0;
    _lang1Label.text = self.textLang1;
    _lang1Label.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0];
    _lang1Label.textColor = [UIColor blackColor];
    [self addSubview:_lang1Label];
    
    _separatorView = [[UIView alloc] init];
    _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    _separatorView.backgroundColor = [UIColor blackColor];
    _separatorView.alpha = 0.5;
    [self addSubview:_separatorView];
    
    _lang2Label = [[UILabel alloc] init];
    _lang2Label.translatesAutoresizingMaskIntoConstraints = NO;
    _lang2Label.numberOfLines = 0;
    _lang2Label.text = self.textLang2;
    _lang2Label.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:14.0];
    _lang2Label.textColor = [UIColor blackColor];
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

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_lang1Label]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_lang1Label)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_lang1Label]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_lang1Label)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_separatorView]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_separatorView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lang1Label]-8-[_separatorView(1)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_lang1Label, _separatorView)]];

//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_lang1TextView]-8-[_separatorView(1)]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_lang1TextView, _separatorView)]];

    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_lang2Label]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_lang2Label)]];
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
    
    UIImage* image = [[RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR cornerRadius:CORNER_RADIUS borderWidth:0 borderColor:nil] resizableImageWithCapInsets:INSETS resizingMode:UIImageResizingModeStretch];
    
    CGRect roundedRect;
    roundedRect = CGRectInset2(rect, UIEdgeInsetsMake(0, 8, 0, 8));

    [image drawInRect:roundedRect];
    
    
}




#pragma mark - Description

- (NSString*) description {
    
    return _lang1Label.text;
}






@end













