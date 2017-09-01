//
//  MATPICItem.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 28.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "MATPICItem.h"



#define GREEN                   [UIColor colorWithRed:51/255.0 green:172/255.0 blue:63/255.0 alpha:1.0]
#define RED                     [UIColor colorWithRed:213/255.0 green:0/255.0 blue:14/255.0 alpha:1.0]
#define BLUE                    [UIColor colorWithRed:0/255.0 green:151/255.0 blue:189/255.0 alpha:1.0]
#define WHITE                   [UIColor whiteColor]
#define ALMOST_WHITE            [UIColor colorWithWhite:0.97 alpha:1.0]
#define GRAY                    [UIColor colorWithWhite:0.85 alpha:1.0]
#define BLACK                   [UIColor blackColor]



#define COLOR_VIEW_ALPHA        0.3
#define COLOR_VIEW_COLOR_CORRECT        GREEN
#define COLOR_VIEW_COLOR_WRONG          RED

#define BORDER_WIDTH        2.0



@implementation MATPICItem

@synthesize image;
@synthesize imageWidth;
@synthesize attributedString;
@synthesize spacing;
@synthesize delegate;
@synthesize state;


- (id) init {
    
    self = [super init];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
//    self.backgroundColor = [UIColor redColor];
    
    return self;
}


- (void) setState:(MATPICItemState)p_state {
    
    state = p_state;
    
    [self _updateView];
}


- (void) createView {
    
//    assert(self.image);
    
    
    // imageView
    
    _imageView = [[UIImageView alloc] initWithImage:self.image];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    _imageView.userInteractionEnabled = YES;
    [self addSubview:_imageView];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_imageView(width)]" options:0 metrics:@{@"width" : @(self.imageWidth)} views:NSDictionaryOfVariableBindings(_imageView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_imageView(height)]" options:0 metrics:@{@"height" : @(self.imageWidth)} views:NSDictionaryOfVariableBindings(_imageView)]];

    [_imageView addGestureRecognizer:[self _createGestureRecognizer]];
    

    // label
    
    _label = [[UILabel alloc] init];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.attributedText = self.attributedString;
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_label];
    
    
    // colorView
    
    _colorView = [[UIView alloc] init];
    _colorView.translatesAutoresizingMaskIntoConstraints = NO;
    _colorView.userInteractionEnabled = NO;
    _colorView.alpha = COLOR_VIEW_ALPHA;
    _colorView.backgroundColor = [UIColor clearColor];

    [self addSubview:_colorView];

    
    // check image view
    
    _checkImageView = [[UIImageView alloc] init];
    _checkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_checkImageView];
    
    
    [self _createImages];
}


- (void) _createImages {
    
    _checkImage = [UIImage imageNamed:@"Check_MATPIC"];
    _crossImage = [UIImage imageNamed:@"Cross_MATPIC"];
}


- (void) _updateView {

    UIColor* color = nil;
    UIImage* checkImage = nil;
    UIColor* borderColor = nil;
    
    switch (self.state) {

        default:
        case Normal:
            color = [UIColor clearColor];
            break;
            
        case Correct:
            color = COLOR_VIEW_COLOR_CORRECT;
            checkImage = _checkImage;
            borderColor = color;
            break;
            
        case Wrong:
            color = COLOR_VIEW_COLOR_WRONG;
            checkImage = _crossImage;
            borderColor = color;
            break;
            
        case Missed:
            color = COLOR_VIEW_COLOR_CORRECT;
            borderColor = color;
            break;
    }
    
    _colorView.backgroundColor = color;
    _checkImageView.image = checkImage;
    
    if (borderColor) {
        
        _imageView.layer.borderColor = borderColor.CGColor;
        _imageView.layer.borderWidth = BORDER_WIDTH;
    }
    else {
        
        _imageView.layer.borderColor = nil;
        _imageView.layer.borderWidth = 0;
    }
}


- (void) layoutSubviews {

    NSLog(@"item layoutsubviews %@", NSStringFromCGRect(self.frame));
    
    [super layoutSubviews];
}


- (void) updateConstraints {

    NSLog(@"item updateconstraints %@", NSStringFromCGRect(self.frame));

    [self _arrangeSubviews];
    
    [self invalidateIntrinsicContentSize];
    
    [super updateConstraints];
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (void) _arrangeSubviews {
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_imageView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_imageView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_imageView]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_imageView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_label]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_label)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_imageView]-(spacing)-[_label]-(>=0)-|" options:0 metrics:@{@"spacing" : @(self.spacing)} views:NSDictionaryOfVariableBindings(_label, _imageView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_colorView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_colorView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_colorView]-(spacing)-[_label]" options:0 metrics:@{@"spacing" : @(self.spacing)} views:NSDictionaryOfVariableBindings(_colorView, _label)]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_checkImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_checkImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_imageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}


- (UITapGestureRecognizer*) _createGestureRecognizer {
    
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    return recognizer;
}


- (void) handleTap:(UIGestureRecognizer*) recognizer {
    
    NSLog(@"tap");
    
    BOOL shouldProcessTap = YES;
    
    if ([self.delegate respondsToSelector:@selector(itemShouldProcessTap:)]) {
        
        shouldProcessTap = [self.delegate itemShouldProcessTap:self];
    }
   
    
    if (shouldProcessTap) {
    
        if ([self.delegate respondsToSelector:@selector(itemDidGetTapped:)]) {
            
            [self.delegate itemDidGetTapped:self];
        }
    }
}



@end
