//
//  LineLayoutView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "LineLayoutView.h"
#import "UIView+RemoveConstraints.h"
#import "LineLayoutSpaceView.h"


#define LineLayoutView_DEBUG        NO

#define ANIMATION_DURATION          0.2


@implementation LineLayoutView

@synthesize horizontalSpacing;
@synthesize verticalSpacing;
@synthesize verticalAlignment;
@synthesize constrainSubviewWidth;


#pragma mark - Init


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}


- (id) init {

    self = [super init];
    
    [self initialize];
    
    return self;
}


- (void) initialize {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.verticalAlignment = 0;
    self.horizontalSpacing = 0;
    self.verticalSpacing = 0;
    
}


#pragma mark - View, Layout, Constraints

- (void) addSubview:(UIView *)subview animated:(BOOL)animated {
    
//    [_layoutedSubviews addObject:subview];

    [super addSubview:subview];

    
    if (animated) {
    
        [self setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            
            [self layoutIfNeeded];
        }];
    }
}


- (void) addSubview:(UIView *)view {
    
    [self addSubview:view animated:NO];
}


- (void) addUnlayoutedSubview:(UIView *)subview {
    
    [super addSubview:subview];
}


- (void) addNonBreakingSpaceWithWidth:(CGFloat) width {
    
    LineLayoutSpaceView* spaceView = [[LineLayoutSpaceView alloc] init];
    spaceView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [spaceView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[spaceView(width)]" options:0 metrics:@{@"width" : @(width)} views:NSDictionaryOfVariableBindings(spaceView)]];
    
    [self addSubview:spaceView animated:NO];
}


- (void) removeSubview:(UIView *)subview animated:(BOOL) animated {

    if (subview.superview == self) {

//        [_layoutedSubviews removeObject:subview];

        [subview removeFromSuperview];

        
        if (animated) {
        
            [self setNeedsUpdateConstraints];
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                
                [self layoutIfNeeded];
            }];
        }
    }
}


- (BOOL) respectSubviewForLineLayout:(UIView*) subview {
    
    return YES;
}


- (NSArray*) customLayoutConstraintsForSubview:(UIView*) subview {
    
    return nil;
}


- (void) layoutSubviews {
    
    NSLog(@"LineLayoutView - layoutSubviews (frame: %@)", NSStringFromCGRect(self.frame));
    
    [super layoutSubviews];

    
//     it appears these lines are necessary for ExerciseTextView2 in a StackView. Since the frame is 0... whatever i dont know.
    
    
    // calling the constraint pass on this view after it has received (and its subviews) its frame(s)
    // after the constraint pass, this method is not called again, only layoutSubviews on the relevant (?) superviews
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];

}


- (void) updateConstraints {

    NSLog(@"LineLayoutView - updateConstraints (frame: %@)", NSStringFromCGRect(self.frame));

    // This is very important and seems to work exactly as it should! This way the self frame is resolved and the frames of the subviews are resolved before it goes into creating the constraints
    // Calling this does NOT end up in an infinite loop because updateConstraints is not called from within layoutSubviews. Theyre like sibling methods
    
//    [super updateConstraintsIfNeeded];
//    [super layoutSubviews];
    
    // these two lines would trigger the whole layout process (including constraint pass again) resulting in an infinite loop
    
//    [self setNeedsLayout];
//    [super layoutIfNeeded];
    
    if (!CGRectEqualToRect(self.frame, CGRectZero)) {
    
        [self _arrangeSubviews];
        
        [self invalidateIntrinsicContentSize];
    }

    [super updateConstraints];
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}



#pragma mark - Subview layout logic

- (void) _arrangeSubviews {

    NSLog(@"LineLayoutView - arrangeSubviews");
    
    for (UIView* subview in self.subviews) {
        
        if (![self respectSubviewForLineLayout:subview]) continue;

        [self removeConstraintsAffectingSubview:subview];
    }

    
    CGFloat maxLineWidth = self.frame.size.width;

    if (LineLayoutView_DEBUG) NSLog(@"maxLineWidth: %f", maxLineWidth);

    NSLog(@"maxLineWidth: %f", maxLineWidth);

    __block int currentLineIndex = -1;
    __block CGFloat currentLineWidth = 0;
    __block UIView* previousView = nil;
    __block UIView* highestViewInCurrentLine = nil;
    __block UIView* highestViewInPreviousLine = nil;
    __block uint numberOfViewsInCurrentLine = 0;
   
    
    // inline blocks
    
    void(^beginNewLine)(void) = ^void(void) {
      
        currentLineWidth = self.layoutMargins.left + self.layoutMargins.right;
        ++currentLineIndex;
        highestViewInPreviousLine = highestViewInCurrentLine;
        highestViewInCurrentLine = nil;
        previousView = nil;
        numberOfViewsInCurrentLine = 0;
    };

    
    beginNewLine();
    


    
    for (UIView* subview in self.subviews) {
        
//        if (![_layoutedSubviews containsObject:subview]) continue;
        
        if (![self respectSubviewForLineLayout:subview]) continue;
        
        if (LineLayoutView_DEBUG) NSLog(@"\n");
        if (LineLayoutView_DEBUG) NSLog(@"subview: %@", subview);

        if (LineLayoutView_DEBUG) NSLog(@"numberOfViewsInCurrentLine: %d", numberOfViewsInCurrentLine);

//        NSLog(@"frame: %@", NSStringFromCGRect(subview.frame));
        
//        [self removeConstraintsAffectingSubview:subview];
        
        CGFloat subviewWidth = subview.frame.size.width;
        CGFloat newLineWidth = currentLineWidth + subviewWidth + ((numberOfViewsInCurrentLine > 0) ? self.horizontalSpacing : 0);
        BOOL fitsInCurrentLine = newLineWidth <= maxLineWidth;
        
        if (LineLayoutView_DEBUG) NSLog(@"currentLineWidth: %f, subviewWidth: %f, newLineWidth: %f, fits: %d", currentLineWidth, subviewWidth, newLineWidth, fitsInCurrentLine);
        if (LineLayoutView_DEBUG) NSLog(@"highestViewInCurrentLine: %@", highestViewInCurrentLine);
        if (LineLayoutView_DEBUG) NSLog(@"highestViewInPreviousLine: %@", highestViewInPreviousLine);
        if (LineLayoutView_DEBUG) NSLog(@"previousView: %@", previousView);
        
//        NSLog(@"currentLineWidth: %f (max: %f) - fits: %d", newLineWidth, maxLineWidth, fitsInCurrentLine);

        
        if (self.constrainSubviewWidth) {
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subview(<=self)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview, self)]];
            
        }

        
        
        if (fitsInCurrentLine) {
            
            [self _placeSubview:subview afterView:previousView relativeToHighestViewInPreviousLine:highestViewInPreviousLine];
            currentLineWidth = newLineWidth;

            
            // at the end
            
            ++numberOfViewsInCurrentLine;
            previousView = subview;
            highestViewInCurrentLine = (subview.frame.size.height > highestViewInCurrentLine.frame.size.height) ? subview : highestViewInCurrentLine;

        }
        else {
            
            beginNewLine();
            currentLineWidth += subviewWidth;
            
            if (![subview isKindOfClass:[LineLayoutSpaceView class]]) {
                
                [self _placeSubviewInNewLine:subview relativeToHighestViewInPreviousLine:highestViewInPreviousLine];

            
                // at the end
                ++numberOfViewsInCurrentLine;
                previousView = subview;
                highestViewInCurrentLine = (subview.frame.size.height > highestViewInCurrentLine.frame.size.height) ? subview : highestViewInCurrentLine;
            }
        }
    }
    
    // finishing constraints for last subview/line ...
    
    if (previousView) {

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(previousView)]];
    }
}


- (void) _placeSubview:(UIView*) newView afterView:(UIView*) previousView relativeToHighestViewInPreviousLine:(UIView*) relativeView {
    
    // horizontal
    
    if (!previousView) {
    
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[newView]" options:0 metrics:@{} views:  NSDictionaryOfVariableBindings(newView)]];
    }
    else {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousView]-(spacing)-[newView]" options:self.verticalAlignment metrics:@{@"spacing" : @(self.horizontalSpacing)} views:  NSDictionaryOfVariableBindings(newView, previousView)]];
    }
    
    // vertical
    
    if (!relativeView) {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=spacing)-[newView]" options:0 metrics:@{@"spacing" : @(self.layoutMargins.top)} views:  NSDictionaryOfVariableBindings(newView)]];
    }
    else {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[relativeView]-(>=spacing)-[newView]" options:0 metrics:@{@"spacing" : @(self.verticalSpacing)} views:  NSDictionaryOfVariableBindings(newView, relativeView)]];
    }
}


- (void) _placeSubviewInNewLine:(UIView*) theView relativeToHighestViewInPreviousLine:(UIView*) relativeView {
    
    // horizontal
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[theView]" options:0 metrics:@{} views:  NSDictionaryOfVariableBindings(theView)]];

    // vertical
    
    if (!relativeView) {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=spacing)-[theView]" options:0 metrics:@{@"spacing" : @(self.layoutMargins.top)} views:  NSDictionaryOfVariableBindings(theView)]];
    }
    else {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[relativeView]-(>=spacing)-[theView]" options:0 metrics:@{@"spacing" : @(self.verticalSpacing)} views:  NSDictionaryOfVariableBindings(theView, relativeView)]];
    }
}


@end
