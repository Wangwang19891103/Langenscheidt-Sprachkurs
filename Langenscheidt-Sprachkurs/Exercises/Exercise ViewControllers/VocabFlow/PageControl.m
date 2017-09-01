//
//  PageControl.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "PageControl.h"
#import "CGExtensions.h"


#define NEUTRAL_DOT_SIZE            5.0f
#define ACTIVE_DOT_SIZE             8.0f

#define PAGE_CONTROL_DOT_SIZE       CGSizeMake(ACTIVE_DOT_SIZE, ACTIVE_DOT_SIZE)

#define SPACING                     6.0f


@implementation PageControl

@synthesize neutralDotColor;
@synthesize activeDotColor;
@synthesize numberOfPages;
@synthesize currentPageIndex;



- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    [self initialize];
    
    return self;
}


- (void) initialize {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _pageDots = [NSMutableArray array];
}


- (void) setCurrentPageIndex:(NSInteger)p_currentPageIndex {
    
    currentPageIndex = p_currentPageIndex;
    
    for (PageControlDot* pageDot in _pageDots) {
        
        pageDot.active = NO;
    }
    
    PageControlDot* activeDot = _pageDots[currentPageIndex];
    activeDot.active = YES;
}


- (void) createView {

    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _innerView = [[UIView alloc] init];
    _innerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: _innerView];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_innerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_innerView)]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_innerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    
    
    for (uint i = 0; i < numberOfPages; ++i) {
        
        PageControlDot* pageDot = [self _newPageDot];
        [_innerView addSubview:pageDot];
        [_pageDots addObject:pageDot];
    }
}


- (void) updateConstraints {
    
    [self _arrangeSubviews];
    
    [super updateConstraints];
}


- (void) _arrangeSubviews {
    
    PageControlDot* previousDot = nil;

    for (uint i = 0; i < _pageDots.count; ++i) {
    
        PageControlDot* pageDot = _pageDots[i];
        
        [pageDot addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[pageDot(width)]" options:0 metrics:@{@"width" : @(PAGE_CONTROL_DOT_SIZE.width)} views:NSDictionaryOfVariableBindings(pageDot)]];
        [pageDot addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageDot(height)]" options:0 metrics:@{@"height" : @(PAGE_CONTROL_DOT_SIZE.height)} views:NSDictionaryOfVariableBindings(pageDot)]];
        
        if (i == 0) {  // first dot
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[pageDot]" options:NSLayoutFormatAlignAllTop metrics:@{} views:NSDictionaryOfVariableBindings(pageDot)]];
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pageDot]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(pageDot)]];
        }
        else if (i == _pageDots.count - 1) {  // last dot
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousDot]-(spacing)-[pageDot]-0-|" options:NSLayoutFormatAlignAllTop metrics:@{@"spacing" : @(SPACING)} views:NSDictionaryOfVariableBindings(pageDot, previousDot)]];
        }
        else {
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousDot]-(spacing)-[pageDot]" options:NSLayoutFormatAlignAllTop metrics:@{@"spacing" : @(SPACING)} views:NSDictionaryOfVariableBindings(pageDot, previousDot)]];
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageDot]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(pageDot)]];
        }
        
        previousDot = pageDot;
    }
}



+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


- (PageControlDot*) _newPageDot {
    
    PageControlDot* pageDot = [[PageControlDot alloc] init];
    pageDot.neutralColor = neutralDotColor;
    pageDot.activeColor = activeDotColor;
    
    return pageDot;
}


- (void) prepareForInterfaceBuilder {
    
    [self initialize];
    
    [self createView];
}

@end





@implementation  PageControlDot

@synthesize neutralColor;
@synthesize activeColor;
@synthesize active;



- (id) init {
    
    self = [super init];

    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    
    return self;
}


- (void) setActive:(BOOL)p_active {
    
    active = p_active;
    
    [self setNeedsDisplay];
}


- (void) drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGColorRef foregroundColor = (active) ? activeColor.CGColor : neutralColor.CGColor;
    CGFloat size = (active) ? ACTIVE_DOT_SIZE : NEUTRAL_DOT_SIZE;
    
    CGContextSetFillColorWithColor(context, foregroundColor);
    
    CGRect ellipseRect = CGRectMake(0, 0, size, size);
    ellipseRect = CGRectCenterInRect(ellipseRect, rect);
    
    CGContextFillEllipseInRect(context, ellipseRect);
    
    CGContextRestoreGState(context);
}

@end











