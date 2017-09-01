//
//  ReorderableLineLayoutView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ReorderableLineLayoutView.h"
#import "CGextensions.h"


#import "ExerciseReorderableLabel.h"

/*
 * - ghost appearance for added subviews
 * - gesture recognizer on each added subview
 * - ever subview gets a unique index and order id?
 * - Important: ReorderableViews can only be dropped NEXT TO other ReorderableViews. This prevents them from being dropped before a fixed view at the beginning of a sentence for example
 *
 */


#define DRAGVIEW_POSITION_OFFSET        CGPointMake(0, 0)

#define ANIMATION_DURATION              0.3


typedef NS_ENUM (NSInteger, PlacementSide) { Left, Right };



@implementation ReorderableLineLayoutView

@synthesize animating;


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}


- (instancetype) init {
    
    self = [super init];
    
    [self initialize];
    
    return self;
}


- (void) initialize {

    [super initialize];
}



#pragma mark - View, Layout, Constraints

- (void) addSubview:(UIView *)view {
    
    [super addSubview:view];
    
    if ([view conformsToProtocol:@protocol(ReorderableViewProtocol)]) {
        
        [view addGestureRecognizer:[self _gestureRecognizer]];
    }
}


- (BOOL) respectSubviewForLineLayout:(UIView *)subview {
    
    if (subview == _dragView) return NO;
    else return YES;
}


#pragma mark - View Logic

- (void) reorderWithDraggedView:(UIView*) draggedView dragView:(UIView*) dragView {
    
//    NSLog(@"re");
    
    UIView* view2 = [self viewUnderView:dragView];
    
//    NSLog(@"view %@", view2);
    
    if ([self viewIsReorderable:view2]) {  // view under dragView is reorderableView
        
        if (view2 != draggedView) {
            
            PlacementSide side = [self placementSideOfView:view2 toView:dragView];
            
            [self placeView:draggedView nextToView:view2 onSide:side withDragView:dragView];
        }
    }
    else if (view2 == self) {  // view under dragView is self (the layout container view)
        
        // find the view thats to the left
        
        UIView* leftView = [self _viewNextToView:dragView placementSide:Left];
        
        NSLog(@"leftView: %@", leftView);
        
        // if there is a view to the left in a straight line (i.e. cursor is not between the lines)
        
        if (leftView) {
            
            if (leftView == draggedView) {
                
                // do nothing since its already at the right place
                
                NSLog(@"leftView is dragged view -> do nothing");
            }
            else if ([self viewIsReorderable:leftView]) {
                
                [self placeView:draggedView nextToView:leftView onSide:Right withDragView:dragView];
            }
        }
        else {
            
            UIView* rightView = [self _viewNextToView:dragView placementSide:Right];
            
            NSLog(@"rightView: %@", rightView);
            
            if (rightView) {
                
                if (rightView == draggedView) {
                    
                    NSLog(@"rightView is dragged view -> do nothing");
                }
                else if ([self viewIsReorderable:rightView]) {

                    [self placeView:draggedView nextToView:rightView onSide:Left withDragView:dragView];
                }
            }
            else {
                
                NSLog(@"No view next to it. THIS SHUDNT HAPPEN!");
            }
        }
    }
}


- (UIView*) viewUnderView:(UIView*) view {
    
    UIView* view2 = [self hitTest:view.center withEvent:nil];
    
    return view2;
}


- (BOOL) viewIsReorderable:(UIView*) view {
    
    return [view conformsToProtocol:@protocol(ReorderableViewProtocol)];
}


- (void) placeView:(UIView*) placedView nextToView:(UIView*) view onSide:(PlacementSide) side withDragView:(UIView*) dragView {
    
//    NSLog(@"place");
    
    NSInteger index1 = [self _indexOfSubview:view];
    NSInteger index2 = [self _indexOfSubview:placedView];
    
    
    if (placedView == view) {
        
        NSLog(@"SAME");
    }
    
    // check if swap is necessary
    
    if ((side == Left && index2 == index1 - 1) || (side == Right && index2 == index1 + 1)) return;

    
    UIView* label = view;
    UIView* placedLabel = placedView;
    
//    NSLog(@"placing '%@' %@ to '%@'.", placedLabel.text, (side==Left)?@"Left":@"Right", label.text);
    
    if (side == Left) {
        
        [self insertSubview:placedView belowSubview:view];
    }
    else {
        
        [self insertSubview:placedView aboveSubview:view];
    }
    
    [self setNeedsUpdateConstraints];
    
    animating = YES;
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        animating = NO;
        
        [self reorderWithDraggedView:placedView dragView:dragView];
    }];
};


- (PlacementSide) placementSideOfView:(UIView*) view1 toView:(UIView*) view2 {

    CGPoint position = [view1 convertPoint:view2.center fromView:view2.superview];
    CGFloat width = view1.frame.size.width;
    CGFloat x = position.x;
    CGFloat halfWidth = width * 0.5;
    
    return (x < halfWidth) ? Left : Right;
};





#pragma mark - Gesture Recognizer, etc.

- (UIPanGestureRecognizer*) _gestureRecognizer {
    
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
    
    return recognizer;
}


- (void) _handlePan:(UIPanGestureRecognizer*) recognizer {
    
//    static UIView<ReorderableViewProtocol>* dragView;
    static CGPoint startPosition;
//    static UIView* previousViewUnderDragView;
    

    
    // inline blocks
    
//    void (^reorder)(void);
    
    void (^translate)(void) = ^void() {
      
        [_dragView.superview bringSubviewToFront:_dragView];
        
        CGPoint translation = [recognizer translationInView:_draggedView];
        CGPoint offsetTranslation = CGPointAddPointTranslation(translation, DRAGVIEW_POSITION_OFFSET);
        _dragView.center = CGPointAddPointTranslation(startPosition, offsetTranslation);
    };
    
    
    
    // state cases
    
    switch (recognizer.state) {

        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"began");
            
            if ([self viewIsMovable:recognizer.view]) {
            
                _draggedView = (UIView<ReorderableViewProtocol>*)recognizer.view;
                _dragView = [self _createDragViewFromView:_draggedView];
                startPosition = [recognizer locationInView:self];
                
                [self addUnlayoutedSubview:_dragView];
                
                [_draggedView setGhostAppearance];
                
                translate();
            }
            else {
                
                recognizer.enabled = NO;
                recognizer.enabled = YES;
            }
        }
            break;
        
        case UIGestureRecognizerStateChanged:
        {
            if (_dragView) {

                translate();
                
                if (!animating) {

                    [self reorderWithDraggedView:_draggedView dragView:_dragView];
                }
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            [_draggedView setNormalAppearance];
            
            [_dragView removeFromSuperview];
    
            _dragView = nil;
            _draggedView = nil;
        }
            break;
            
        default:
            break;
    }
}


- (UIView<ReorderableViewProtocol>*) _createDragViewFromView:(UIView<ReorderableViewProtocol>*) view {
    
    UIView<ReorderableViewProtocol>* dragView = [self _createCopyFromView:view];

    // this is very important! if this is not set the views frame will get lost during layout pass because it does not get layouted via constraints but only by setting the frame
    
    dragView.translatesAutoresizingMaskIntoConstraints = YES;
    dragView.userInteractionEnabled = NO;
    
    return dragView;
}


- (id) _createCopyFromView:(UIView*) view {
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:view]];
}


- (BOOL) viewIsMovable:(UIView*) view {
    
    return YES;
}



#pragma mark - Utility

- (NSInteger) _indexOfSubview:(UIView*) view {
    
    for (uint index = 0; index < self.subviews.count; ++index) {
        
        UIView* subview = self.subviews[index];
        
        if (subview == view) {
            
            return index;
        }
    }
    
    return NSNotFound;
}


- (UIView*) _viewNextToView:(UIView*) view placementSide:(PlacementSide) side {
    
    CGPoint position = view.center;
    CGFloat x = position.x;
    
    while (x >= 0 && x <= self.frame.size.width) {

        CGPoint searchPosition = CGPointMake(x, position.y);
        
        UIView* viewAtPosition = [self hitTest:searchPosition withEvent:nil];  // important: tested views must be interactable
        
        if (viewAtPosition != self) {
            
            return viewAtPosition;
        }
        
        x = (side == Left) ? x-1 : x+1;
    }
    
    return nil;
}







@end













