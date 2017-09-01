//
//  ScrollView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 18.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "FadeView.h"

@implementation FadeView

@synthesize viewToFade;
@synthesize topLimitView;
@synthesize bottomLimitView;
@synthesize enabled;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    return self;
}


- (id) init {
    
    self = [super init];
    
    return self;
}


- (void) awakeFromNib {
    
    [super awakeFromNib];
    
    [self _addLayers];
    
}


- (void) createView {  // only call this when added programmatically
    
    [self _addLayers];
}


- (void) layoutSubviews {
    
    [super layoutSubviews];
    
    [self _layoutLayers];
}


- (void) _addLayers {

    if (!self.enabled) return;

    
    _maskLayer = [CALayer layer];
    _maskLayer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:self.minimumAlpha].CGColor;
    
    _layerTop = [CAGradientLayer layer];
    _layerTop.opaque = NO;
    _layerTop.colors = [self _gradientColorsWithCount:100 fromValue:self.minimumAlpha toValue:1.0 withCurve:Sinus];
    _layerTop.locations = [self _numbersWithCount:100 fromValue:0 toValue:1.0 withCurve:Linear];
    _layerTop.startPoint = CGPointMake(0.5, 0.0);
    _layerTop.endPoint = CGPointMake(0.5, 1.0);
    [_maskLayer addSublayer:_layerTop];

    _layerBottom = [CAGradientLayer layer];
    _layerBottom.colors = [self _gradientColorsWithCount:100 fromValue:self.minimumAlpha toValue:1.0 withCurve:Sinus];
    _layerBottom.locations = [self _numbersWithCount:100 fromValue:0 toValue:1.0 withCurve:Linear];
    _layerBottom.startPoint = CGPointMake(0.5, 1.0);
    _layerBottom.endPoint = CGPointMake(0.5, 0.0);
    [_maskLayer addSublayer:_layerBottom];

    _middleLayer = [CALayer layer];
    _middleLayer.backgroundColor = [UIColor whiteColor].CGColor;
    [_maskLayer addSublayer:_middleLayer];
    
//    NSLog(@"colors: %@", _layerTop.colors);
//    NSLog(@"locations: %@", _layerTop.locations);
    
    
    self.layer.mask = _maskLayer;
}


- (NSArray*) _gradientColorsWithCount:(int) count fromValue:(CGFloat) fromValue toValue:(CGFloat) toValue withCurve:(FadeViewCurve) curve {
    
    NSMutableArray* colors = [NSMutableArray array];
    
    NSArray* alphas = [self _numbersWithCount:count fromValue:fromValue toValue:toValue withCurve:curve];
    
    for (NSNumber* alpha in alphas) {
        
        [colors addObject:(id)[[UIColor whiteColor] colorWithAlphaComponent:[alpha floatValue]].CGColor];
    }
    
    return colors;
}

- (NSArray*) _numbersWithCount:(int) count fromValue:(CGFloat) fromValue toValue:(CGFloat) toValue withCurve:(FadeViewCurve) curve {

    NSMutableArray* numbers = [NSMutableArray array];
    
    if (curve == Linear) {
        
        CGFloat range = toValue - fromValue;
        CGFloat stepWidth = range / (count - 1);
        CGFloat currentValue = fromValue;
        
        for (int i = 0; i < count; ++i) {
            
            float result = currentValue;
            currentValue += stepWidth;
            
            [numbers addObject:@(result)];
        }
        
    }
    else if (curve == Sinus) {
        
        CGFloat range = toValue - fromValue;
        CGFloat stepWidth = range / (count - 1);
        CGFloat currentValue = fromValue;
        
        for (int i = 0; i < count; ++i) {
            
            float result = sinf((currentValue - 0.5) * M_PI) * 0.5 + 0.5;
            currentValue += stepWidth;
            
            [numbers addObject:@(result)];
        }
    }
    else if (curve == Cubic) {
        
        CGFloat range = toValue - fromValue;
        CGFloat stepWidth = range / (count - 1);
        CGFloat currentValue = fromValue;
        
        for (int i = 0; i < count; ++i) {
            
            float result = powf((((currentValue * 2) - 1) / 1000), (1.0/3.0)) * 10 * 0.5 + 0.5;
            
            NSLog(@"x: %f ----- y: %f", currentValue, result);
            currentValue += stepWidth;
            
            
            
            [numbers addObject:@(result)];
        }
    }

    return numbers;
}






- (void) _layoutLayers {
    
    // mask layer
    
    _maskLayer.frame = self.bounds;
    
    CGRect viewToFadeFrame = [self convertRect:viewToFade.frame fromView:viewToFade.superview];
    CGFloat viewToFadeTopY = viewToFadeFrame.origin.y;
    CGFloat viewToFadeBottomY = viewToFadeFrame.origin.y + viewToFadeFrame.size.height;

    CGRect topLimitViewFrame = [self convertRect:topLimitView.frame fromView:topLimitView.superview];
    CGFloat topLimitViewTopY = topLimitViewFrame.origin.y;
    CGFloat topLimitViewBottomY = topLimitViewFrame.origin.y + topLimitViewFrame.size.height;

    CGRect bottomLimitViewFrame = [self convertRect:bottomLimitView.frame fromView:bottomLimitView.superview];
    CGFloat bottomLimitViewTopY = bottomLimitViewFrame.origin.y;
    CGFloat bottomLimitViewBottomY = bottomLimitViewFrame.origin.y + bottomLimitViewFrame.size.height;

//    CGFloat topLimitViewBottomY = topLimitViewFrameInLocalCoordinates.origin.y + topLimitViewFrameInLocalCoordinates.size.height;
//    CGFloat topHeight = MAX(topLimit - topLimitViewBottomY, 0);
//    
//    CGFloat bottomHeight = MAX(self.bottomLimitView.frame.origin.y - bottomLimit , 0);

    CGFloat topLayerTopY = topLimitViewBottomY;
    CGFloat topLayerBottomY = MIN(topLimitViewBottomY, viewToFadeTopY) + self.adjustmentTopLimit;
    CGFloat topLayerHeight = ABS(topLayerBottomY - topLayerTopY);
    
    CGFloat bottomLayerTopY = MIN(viewToFadeBottomY, bottomLimitViewTopY) - self.adjustmentBottomLimit;
    CGFloat bottomLayerBottomY = bottomLimitViewTopY;
    CGFloat bottomLayerHeight = ABS(bottomLayerBottomY - bottomLayerTopY);
    
    
    // top gradient layer
    
    _layerTop.frame = CGRectMake(0, topLayerTopY - self.adjustmentTopReach, self.frame.size.width, topLayerHeight + self.adjustmentTopReach);
    
    
    // bottom gradient layer
    
    _layerBottom.frame = CGRectMake(0, bottomLayerTopY, self.frame.size.width, bottomLayerHeight + self.adjustmentBottomReach);
    
    
    // middle layer
    
    _middleLayer.frame = CGRectMake(0,
                                    _layerTop.frame.origin.y + _layerTop.frame.size.height,
                                    self.frame.size.width,
                                    _layerBottom.frame.origin.y - (_layerTop.frame.origin.y + _layerTop.frame.size.height));
    
    
}


@end
