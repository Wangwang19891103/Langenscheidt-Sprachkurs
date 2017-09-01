//
//  LineLayoutView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "LineLayoutView2.h"
#import "UIView+RemoveConstraints.h"
#import "LineLayoutSpaceView.h"
//#import "UIView+SubviewAtPosition.h"
#import "LineLayoutConnectionView.h"
#import "LineLayoutContainerView.h"


#define LineLayoutView_DEBUG        NO

#define ANIMATION_DURATION          0.2


@implementation LineLayoutView2

@synthesize horizontalSpacing;
@synthesize verticalSpacing;
@synthesize verticalAlignment;
@synthesize constrainSubviewWidth;
@synthesize delegate;


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
    [self setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    _subviewsToLayout = [NSMutableArray array];
    
}


#pragma mark - View, Layout, Constraints

- (void) addSubview:(UIView *)subview animated:(BOOL)animated {
    
//    [_layoutedSubviews addObject:subview];

    [super addSubview:subview];

    [_subviewsToLayout addObject:subview];
    
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


- (void) addCustomLayoutedSubview:(UIView *)subview {
    
    [_subviewsToLayout addObject:subview];  // this needs tweaking. used for custom keyboard backspace and enter button
    
    [super addSubview:subview];
}


- (void) addNonBreakingSpaceWithWidth:(CGFloat) width {
    
    LineLayoutSpaceView* spaceView = [[LineLayoutSpaceView alloc] init];
    spaceView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [spaceView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[spaceView(width)]" options:0 metrics:@{@"width" : @(width)} views:NSDictionaryOfVariableBindings(spaceView)]];
    
    [self addSubview:spaceView animated:NO];
}


- (void) addConnectionToken {
    
    LineLayoutConnectionView* connectionView = [[LineLayoutConnectionView alloc] init];
    connectionView.translatesAutoresizingMaskIntoConstraints = NO;

    [connectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[connectionView(0)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(connectionView)]];
    
    [self addSubview:connectionView animated:NO];
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
    
    if ([self.delegate respondsToSelector:@selector(respectSubviewForLineLayout:)]) {
        
        return [self.delegate respectSubviewForLineLayout:subview];
    }
    else {
        
        return YES;
    }
}


- (NSArray*) customLayoutConstraintsForSubview:(UIView*) subview {
    
    if ([self.delegate respondsToSelector:@selector(lineLayoutView:customLayoutConstraintsForSubview:)]) {
        
        return [self.delegate lineLayoutView:self customLayoutConstraintsForSubview:subview];
    }
    else {
        
        return nil;
    }
}


- (void) layoutSubviews {
    
//    NSLog(@"LineLayoutView - layoutSubviews (frame: %@)", NSStringFromCGRect(self.frame));
    
    [super layoutSubviews];
    
    // calling the constraint pass on this view after it has received (and its subviews) its frame(s)
    // after the constraint pass, this method is not called again, only layoutSubviews on the relevant (?) superviews
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
}


- (void) updateConstraints {
    
//    NSLog(@"LineLayoutView - updateConstraints (frame: %@)", NSStringFromCGRect(self.frame));
    
    BOOL frameChanged = !CGRectEqualToRect(self.frame, _previousFrame);
    
    if (!CGRectEqualToRect(self.frame, CGRectZero) && frameChanged) {
        
        _previousFrame = self.frame;
        
//        [self _layoutSubviewsToLayout];
        
        [self _arrangeSubviews];
        
//        [self invalidateIntrinsicContentSize];
    }
    
    [super updateConstraints];
}


//- (void) _layoutSubviewsToLayout {
//    
//    for (UIView* subview in _subviewsToLayout) {
//        
//        [subview setNeedsLayout];
//        [subview layoutIfNeeded];
//    }
//}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (BOOL) _viewIsNonBreakingSpace:(UIView*) view {
    
    return [view isKindOfClass:[LineLayoutSpaceView class]];
}


- (BOOL) _viewIsConnectionToken:(UIView*) view {
    
    BOOL is = [view isKindOfClass:[LineLayoutConnectionView class]];
    
//    NSLog(@"isConnectionToken: %@ -- %@", is ? @"YES" : @"NO", view);
    
    return is;
}


- (BOOL) _viewIsControlToken:(UIView*) view {
    
    return [self _viewIsNonBreakingSpace:view] || [self _viewIsConnectionToken:view];
}


- (BOOL) _viewIsLineContainer:(UIView*) view {
    
    return [view isKindOfClass:[LineLayoutContainerView class]];
}



#pragma mark - Intersecting Subviews

- (NSArray*) _subviewsIntersectingRect:(CGRect) rect ignoringViews:(NSArray*) ignoreViews {
    
    NSMutableArray* subviewsIntersecting = [NSMutableArray array];
    
    for (UIView* subview in self.subviews) {
        
        
        if ([ignoreViews containsObject:subview]) continue;
        
        
        if ([self _subview:subview isIntersectingRect:rect]) {
            
//            NSLog(@"intersect: %@, %@", NSStringFromCGRect(rect), subview);
            
            [subviewsIntersecting addObject:subview];
        }
    }
    
    return subviewsIntersecting;
}


- (BOOL) _subview:(UIView*) subview isIntersectingRect:(CGRect) rect {
    
    return CGRectIntersectsRect(subview.frame, rect);
}




#pragma mark - Subview layout logic

- (void) _arrangeSubviews {

//    NSLog(@"LineLayoutView2 - arrangeSubviews (%@)", self.accessibilityIdentifier);
    
    
    // remove all line containers
    
    for (UIView* subview in self.subviews) {
        
        if ([self _viewIsLineContainer:subview]) {
            
            [subview removeFromSuperview];
        }
    }
    
    
    
    
    
    for (UIView* subview in _subviewsToLayout) {
        
        if (![self respectSubviewForLineLayout:subview]) continue;

        [self removeConstraintsAffectingSubview:subview];
    }

    


//    NSLog(@"maxLineWidth: %f", maxLineWidth);

    __block CGFloat maxLineWidth;
    __block int currentLineIndex = -1;
//    __block CGFloat currentLineWidth = 0;
    __block UIView* previousView = nil;
    __block UIView* previousPreviousView = nil;
//    __block UIView* highestViewInCurrentLine = nil;
//    __block UIView* highestViewInPreviousLine = nil;
    __block LineLayoutContainerView* lineContainer = nil;
    __block uint numberOfViewsInCurrentLine = 0;
    __block UIView* farthestViewInView = nil;
    __block UIView* farthestViewInCurrentLine = nil;
   
    NSMutableArray* subviewsToPlace = [NSMutableArray array];
    UIView* subviewToPlace = nil;

    
    
    // inline blocks
    
    void(^beginNewLine)(void) = ^void(void) {
      
//        currentLineWidth = self.layoutMargins.left + self.layoutMargins.right;
        ++currentLineIndex;
//        highestViewInPreviousLine = highestViewInCurrentLine;
//        highestViewInCurrentLine = nil;
        lineContainer = [self _addNewLineContainerUnderLineContainer:lineContainer];
        maxLineWidth = self.frame.size.width - self.layoutMargins.left- self.layoutMargins.right - lineContainer.layoutMargins.left - lineContainer.layoutMargins.right;
        previousView = nil;
        previousPreviousView = nil;
        numberOfViewsInCurrentLine = 0;
        farthestViewInView = (farthestViewInView.frame.origin.x + farthestViewInView.frame.size.width > farthestViewInCurrentLine.frame.origin.x + farthestViewInCurrentLine.frame.size.width) ? farthestViewInView : farthestViewInCurrentLine;
        farthestViewInCurrentLine = nil;
        
//        NSLog(@"maxLineWidth: %f", maxLineWidth);
    };

    
    void(^finishCurrentLine)(void) = ^void(void) {
      
        if (previousView && lineContainer) {
        
            [lineContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousView]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(previousView)]];
        }
    };
    
    
    

    
    
    
    
    
    
    
    // begins here
    
    
    beginNewLine();
    


    
//    for (UIView* subview in self.subviews) {
    for (int i = 0; i < _subviewsToLayout.count; ++i) {

        subviewsToPlace = [NSMutableArray array];
        
//        subviewToPlace = _subviewsToLayout[i];
        
        
//        NSLog(@"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        
        
//        BOOL continueMainLoop = NO;
        
        subviewToPlace = _subviewsToLayout[i];
        
        
//        NSLog(@"subviewToPlace: %@", subviewToPlace);
        
        
        // case NonBreakingSpace
        
        if ([self _viewIsNonBreakingSpace:(subviewToPlace = _subviewsToLayout[i])]) {
        
//            NSLog(@"isNonBreakingSpace");
            
            while (i < _subviewsToLayout.count && [self _viewIsControlToken:(subviewToPlace = _subviewsToLayout[i])]) {
                
                // if connection token after a space view -> break out of this loop, continue the main loop and let the other check find the connection token
                
//                NSLog(@"looping to next non-control view: %@", subviewToPlace);
                
                if ([self _viewIsConnectionToken:subviewToPlace]) {
                    
                    //                --i;
//                    continueMainLoop = YES;
                    
//                    NSLog(@"connection token found. Breaking loop.");
                    
                    [subviewsToPlace removeAllObjects];
                    
                    break;
                }
                
                
                [self removeConstraintsAffectingSubview:subviewToPlace];
                
                [subviewsToPlace addObject:subviewToPlace];
                
                ++i;
                
//                subviewToPlace = _subviewsToLayout[i];
            }
        }

//        NSLog(@"(subview after NBS loop: %@)", subviewToPlace);
        
        
        // case ConnectionToken
        
//        NSAssert(i < _subviewsToLayout.count, @"uh oh");
        
        if (i < _subviewsToLayout.count && [self _viewIsConnectionToken:(subviewToPlace = _subviewsToLayout[i])]) {
            
//            NSLog(@"view is connection token: %@", subviewToPlace);
            
            while (i > 0 && [self _viewIsControlToken:(subviewToPlace = _subviewsToLayout[i])]) {  // spool back till a non-control token is found
                
//                NSLog(@"spooling back to non control token: %@", subviewToPlace);
                
                [subviewToPlace removeFromSuperview];
                
                --i;
                
//                subviewToPlace = _subviewsToLayout[i];
                
                //                [self removeConstraintsAffectingSubview:subviewToPlace];
                
            }

//            NSLog(@"(subview after CT loop: %@", subviewToPlace);
            
            // subviewToPlace is now a non-control token -> remove from superview and add to array
            
            [subviewToPlace removeFromSuperview];
            
            [subviewsToPlace addObject:subviewToPlace];
            
            previousView = previousPreviousView;
            
            
            // loop through the following control tokens until the next non-control token. add all of them to array
            
            ++i;
            
//            subviewToPlace = _subviewsToLayout[i];
            
            while (i < _subviewsToLayout.count && [self _viewIsControlToken:(subviewToPlace = _subviewsToLayout[i])]) {
                
//                NSLog(@"looping to next non control view: %@", subviewToPlace);
                
                [subviewToPlace removeFromSuperview];
                
                [subviewsToPlace addObject:subviewToPlace];
                
                ++i;
                
//                subviewToPlace = _subviewsToLayout[i];
            }
            
//            // subviewToPlace is now a non-control token -> removefrom superview and add to array
//            
            [subviewToPlace removeFromSuperview];
//
//            [subviewsToPlace addObject:subviewToPlace];
            
            
        }
        
        // --

        
        if (![self _viewIsControlToken:subviewToPlace]) {  // applies to last view anyway
            
            [subviewsToPlace addObject:subviewToPlace];
        }
        
        
//        NSLog(@"subviewsToPlace: %@", subviewsToPlace);

        
        if (subviewsToPlace.count == 0) {
            
            continue;
        }
        
        
//        NSLog(@"------------------------------------------------");
        
        
        if (![self respectSubviewForLineLayout:subviewToPlace]) continue;
        
        
//        [self removeConstraintsAffectingSubview:subviewToPlace];

        
        
        
        NSArray* customConstraints = [self customLayoutConstraintsForSubview:subviewToPlace];
        
        if (customConstraints) {
            
//            NSLog(@"Using custom constraints for subview: %@", subviewToPlace);
            
            [self addConstraints:customConstraints];

            [super layoutSubviews];
            
            continue;
        }
        
        
        
        
        if (LineLayoutView_DEBUG) NSLog(@"\n");
        if (LineLayoutView_DEBUG) NSLog(@"subview: %@", subviewToPlace);

        if (LineLayoutView_DEBUG) NSLog(@"numberOfViewsInCurrentLine: %d", numberOfViewsInCurrentLine);

//        NSLog(@"frame: %@", NSStringFromCGRect(subview.frame));
        
        
//        CGFloat subviewWidth = subview.frame.size.width;
        
//        NSLog(@"previousView: %@", NSStringFromCGRect(previousView.frame));
//        NSLog(@"subview: %@", NSStringFromCGRect(subview.frame));
        
        
//        if (LineLayoutView_DEBUG) NSLog(@"highestViewInCurrentLine: %@", highestViewInCurrentLine);
//        if (LineLayoutView_DEBUG) NSLog(@"highestViewInPreviousLine: %@", highestViewInPreviousLine);
//        if (LineLayoutView_DEBUG) NSLog(@"previousView: %@", previousView);
        
        
        if (self.constrainSubviewWidth) {
            
            // ! Does this work with the new subviewsToPlace implementation?
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subviewToPlace(<=self)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subviewToPlace, self)]];
            
        }

//        NSLog(@"--------------------------------");
//        NSLog(@"subviewsToPlace: %@", subviewsToPlace);

//        NSLog(@"line subviews: \n%@", lineContainer.subviews);
        
        BOOL fitsInCurrentLine =
        // calculating if view fits in same line
        ({
            // calculating space to the right
            
            CGRect previousViewFrameInSelfCoordinates = [self convertRect:previousView.frame fromView:lineContainer];
            
            CGFloat previousX = (previousView) ? (previousViewFrameInSelfCoordinates.origin.x + previousViewFrameInSelfCoordinates.size.width) : self.layoutMargins.left + lineContainer.layoutMargins.left;
            CGFloat previousY = (previousView) ? (previousViewFrameInSelfCoordinates.origin.y + previousViewFrameInSelfCoordinates.size.height) : self.layoutMargins.top + lineContainer.layoutMargins.top;
            
//            NSLog(@"previousView: %@", previousView);
//            NSLog(@"previous position: %f, %f", previousX, previousY);
            
            CGFloat widthOfSubviewsToPlace = ({
                
                CGFloat width = 0;
                
                for (UIView* subviewToPlace in subviewsToPlace) {
                    
                    width += subviewToPlace.frame.size.width;
                }
                
                width;
            });
            
//            NSLog(@"width: %f", widthOfSubviewsToPlace);
            
//            NSLog(@"width left: %f", maxLineWidth - previousX - widthOfSubviewsToPlace);
            
            CGFloat heightOfSubviewsToPlace = ({
                
                UIView* lastSubviewToPlace = subviewsToPlace.lastObject;
                
                lastSubviewToPlace.frame.size.height;
            });
            
            CGRect necessaryRect =
            ({
                CGFloat top = (currentLineIndex == 0) ? self.layoutMargins.top : self.verticalSpacing;
                CGFloat bottom = self.verticalSpacing;
                CGFloat right = self.horizontalSpacing;
                
                CGRectMake(previousX, previousY - top, widthOfSubviewsToPlace + right, heightOfSubviewsToPlace + top + bottom);
            });
            
            // check if there is a subview intersecting with necessaryRect
            
            BOOL intersecting = [[self _subviewsIntersectingRect:necessaryRect ignoringViews:@[lineContainer]] count] != 0;
            
//            if (intersecting) {
//                
//                [self subviewsIntersectingRect:necessaryRect];
//            }
            
//            NSLog(@"intersecting: %@", intersecting ? @"YES" : @"NO");
            
            //            CGFloat subviewWidth = subview.frame.size.width;
            CGFloat newLineWidth = previousX + widthOfSubviewsToPlace + ((numberOfViewsInCurrentLine > 0) ? self.horizontalSpacing : 0) + self.layoutMargins.right;
            BOOL fitsInCurrentLine = newLineWidth <= maxLineWidth;
            
//            NSLog(@"fitsInCurrentLine: %@", fitsInCurrentLine ? @"YES" : @"NO");
            
            !intersecting && fitsInCurrentLine;
        });
        
        
        if (fitsInCurrentLine) {
            
//            NSLog(@"place in current line");
            
            for (UIView* subviewToPlace in subviewsToPlace) {
                
                if (![self _viewIsConnectionToken:subviewToPlace]) {
                    
                    [self _placeSubview:subviewToPlace inLineContainer:lineContainer];
                    
                    previousPreviousView = previousView;
                    previousView = subviewToPlace;
                    
                    ++numberOfViewsInCurrentLine;
                    
//                    highestViewInCurrentLine = (subviewToPlace.frame.size.height > highestViewInCurrentLine.frame.size.height) ? subviewToPlace : highestViewInCurrentLine;
                    farthestViewInCurrentLine = subviewToPlace;
                }
            }
        }
        else {
            
//            NSLog(@"place in NEW line");
            
            finishCurrentLine();
            beginNewLine();
            
            for (UIView* subviewToPlace in subviewsToPlace) {

                if (![self _viewIsControlToken:subviewToPlace]) {
                    
                    [self _placeSubview:subviewToPlace inLineContainer:lineContainer];
                    
                    
                    // at the end
                    ++numberOfViewsInCurrentLine;

//                    previousPreviousView = previousView;
                    previousView = subviewToPlace;
                    
//                    highestViewInCurrentLine = (subviewToPlace.frame.size.height > highestViewInCurrentLine.frame.size.height) ? subviewToPlace : highestViewInCurrentLine;
                    farthestViewInCurrentLine = subviewToPlace;
                }
            }
        }
        
        [super layoutSubviews];  // what does this do?
        
    }
    
    
    finishCurrentLine();
    
    
    
    // finishing constraints for subview with largest (y + height)

//    UIView* bottomMostSubview = nil;
//    CGFloat maxBottom = 0;
//    
//    for (UIView* subview in _subviewsToLayout) {
//        
//        CGFloat bottom = subview.frame.origin.y + subview.frame.size.height;
//        
//        if (bottom > maxBottom) {
//            
//            maxBottom = bottom;
//            bottomMostSubview = subview;
//        }
//    }
    
//    if (bottomMostSubview) {
//    
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bottomMostSubview]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(bottomMostSubview)]];
//    }

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[lineContainer]-(>=bottom)-|" options:0 metrics:@{@"bottom" : @(self.layoutMargins.bottom)} views:NSDictionaryOfVariableBindings(lineContainer)]];

    
    // finishing constraints for farthest view in view (trailing constraint)
    
//    if (farthestViewInView) {
//    
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[farthestViewInView]-(>=right)-|" options:0 metrics:@{@"right" : @(self.layoutMargins.right)} views:NSDictionaryOfVariableBindings(farthestViewInView)]];
//    }
}


- (LineLayoutContainerView*) _addNewLineContainerUnderLineContainer:(UIView*) aboveLineContainer {
    
    LineLayoutContainerView* newLineContainer = [[LineLayoutContainerView alloc] init];
    newLineContainer.translatesAutoresizingMaskIntoConstraints = NO;
    newLineContainer.layoutMargins = UIEdgeInsetsZero;
    [super addSubview:newLineContainer];
    
    if (aboveLineContainer) {
    
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[newLineContainer]-(>=0)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(newLineContainer)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[aboveLineContainer]-(spacing)-[newLineContainer]" options:0 metrics:@{@"spacing" : @(self.verticalSpacing)} views:NSDictionaryOfVariableBindings(newLineContainer, aboveLineContainer)]];
    }
    else {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[newLineContainer]-(>=0)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(newLineContainer)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[newLineContainer]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(newLineContainer)]];
    }
        
    return newLineContainer;
}


- (void) _placeSubview:(UIView*) newView inLineContainer:(UIView*) lineContainer {
    
    // horizontal
    
//    if (!previousView) {
//    
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[newView]" options:0 metrics:@{} views:  NSDictionaryOfVariableBindings(newView)]];
//    }
//    else {
//
    
    UIView* previousView = lineContainer.subviews.lastObject;

    [lineContainer addSubview:newView];

    if (previousView) {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[previousView]-(spacing)-[newView]" options:self.verticalAlignment metrics:@{@"spacing" : @(self.horizontalSpacing)} views:  NSDictionaryOfVariableBindings(newView, previousView)]];
    }
    else {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[newView]" options:self.verticalAlignment metrics:@{} views:  NSDictionaryOfVariableBindings(newView)]];
    }
//    }
    
    // vertical
    
//    if (!relativeView) {
//        
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=spacing)-[newView]" options:0 metrics:@{@"spacing" : @(self.layoutMargins.top)} views:  NSDictionaryOfVariableBindings(newView)]];
//    }
//    else {
//        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[newView]-(>=0)-|" options:0 metrics:@{} views:  NSDictionaryOfVariableBindings(newView)]];
//    }
    
    [lineContainer setNeedsLayout];
    [lineContainer layoutIfNeeded];
}


//- (void) _placeSubviewInNewLine:(UIView*) theView relativeToHighestViewInPreviousLine:(UIView*) relativeView {
//    
//    // horizontal
//    
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[theView]" options:0 metrics:@{} views:  NSDictionaryOfVariableBindings(theView)]];
//
//    // vertical
//    
//    if (!relativeView) {
//        
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=spacing)-[theView]" options:0 metrics:@{@"spacing" : @(self.layoutMargins.top)} views:  NSDictionaryOfVariableBindings(theView)]];
//    }
//    else {
//        
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[relativeView]-(>=spacing)-[theView]" options:0 metrics:@{@"spacing" : @(self.verticalSpacing)} views:  NSDictionaryOfVariableBindings(theView, relativeView)]];
//    }
//}


@end
