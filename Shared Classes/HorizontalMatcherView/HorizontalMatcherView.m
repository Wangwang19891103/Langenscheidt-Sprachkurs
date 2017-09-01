//
//  HorizontalMatcherView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "HorizontalMatcherView.h"
#import "NSArray+Extensions.h"
#import "UIView+RemoveConstraints.h"
#import "CGExtensions.h"


#define DRAGVIEW_POSITION_OFFSET        CGPointMake(0, 0)

#define ANIMATION_DURATION              0.3

#define SCORE_PER_PAIR                  2


@implementation HorizontalMatcherView

@synthesize pairs;
@synthesize animating;



#pragma mark - Init

- (id) init {
    
    self = [super init];
    
    [self initialize];
    
    return self;
}


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}


- (void) initialize {
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _pairDict = [NSMutableDictionary dictionary];
}



#pragma mark - Setters

- (void) setPairs:(NSMutableArray *)p_pairs {
    
    pairs = p_pairs;
}



#pragma mark - View, Layout, Constraints

- (void) didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    if (self.superview) {
        
    }
}


- (void) createView {
    
    [self _createScrambledButtons];
}


- (void) layoutSubviews {
    
    NSLog(@"layoutSubviews");
    
    [super layoutSubviews];
    
    
    // It seems that this does not cause an infinite loop. It seems that layoutSubviews is not automatically called when updateConstraintsIfNeeded has been called. layoutSubviews only gets called when the constraints actually changed in the last pass (updateConstraints), it seems.
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    // do something here
}


- (void) updateConstraints {
    
    NSLog(@"updateConstraints");
    
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



#pragma mark - View Layout Logic

- (void) _arrangeSubviews {
    
//    NSLog(@"arrangeSubviews");
    
    CGFloat verticalSpacing = 5;
    CGFloat horizontalSpacing = -3;
    
    UIView* highestViewInPreviousRow = nil;

    UIButton* leftButton = nil;
    UIButton* rightButton = nil;

    for (uint index = 0;  index < _leftButtons.count; ++index) {
        
        leftButton = _leftButtons[index];
        rightButton = _rightButtons[index];
        
        [self removeConstraintsAffectingSubview:leftButton];
        [self removeConstraintsAffectingSubview:rightButton];
    }
    
    for (uint index = 0;  index < _leftButtons.count; ++index) {
        
        leftButton = _leftButtons[index];
        rightButton = _rightButtons[index];
        
//        [self removeConstraintsAffectingSubview:leftButton];
//        [self removeConstraintsAffectingSubview:rightButton];

        
//        NSLog(@"leftButton frame: %@ - rightButton frame: %@", NSStringFromCGRect(leftButton.frame), NSStringFromCGRect(rightButton.frame));
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[leftButton(rightButton)]-(horizontalSpacing)-[rightButton]-|" options:0 metrics:@{@"horizontalSpacing" : @(horizontalSpacing)} views:NSDictionaryOfVariableBindings(leftButton, rightButton)]];
        
        if (highestViewInPreviousRow) {
        
            // putting the height constraint for the highestViewInPreviousRow makes it so that it gets a bigger height (from current left or right button) if needed. This was actually a mistake but turns out it does what i wanted, miracally!
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[highestViewInPreviousRow(rightButton)]-(verticalSpacing)-[leftButton(rightButton)]" options:0 metrics:@{@"verticalSpacing" : @(verticalSpacing)} views:NSDictionaryOfVariableBindings(highestViewInPreviousRow, leftButton, rightButton)]];

            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[highestViewInPreviousRow(leftButton)]-(verticalSpacing)-[rightButton(leftButton)]" options:0 metrics:@{@"verticalSpacing" : @(verticalSpacing)} views:NSDictionaryOfVariableBindings(highestViewInPreviousRow, rightButton, leftButton)]];
        }
        else {
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[leftButton(rightButton)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(leftButton, rightButton)]];
            
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[rightButton(leftButton)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(rightButton, leftButton)]];
        }
        
        highestViewInPreviousRow = (leftButton.frame.size.height > rightButton.frame.size.height) ? leftButton : rightButton;
    }
    
    if (highestViewInPreviousRow) {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[highestViewInPreviousRow]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(highestViewInPreviousRow)]];
    }
}


- (void) _createScrambledButtons {
    
    NSMutableArray* leftButtons = [NSMutableArray array];
    NSMutableArray* rightButtons = [NSMutableArray array];
    
    uint tag = 0;
    _maxScore = 0;
    
    for (NSArray* pairArray in self.pairs) {
        
        NSString* leftString = pairArray[0];
        NSString* rightString = pairArray[1];
        
        MatcherLabel* leftButton = [self _newLabelWithString:leftString side:Left];
        leftButton.state = Immovable;
        leftButton.tag = 1000 + tag;
        
        MatcherLabel* rightButton = [self _newLabelWithString:rightString side:Right];
        rightButton.state = Normal;
        rightButton.tag = 2000 + tag;
        
        [_pairDict setObject:rightButton forKey:[NSValue valueWithNonretainedObject:leftButton]];
        
        [self addSubview:leftButton];
        [self addSubview:rightButton];
        
        [leftButtons addObject:leftButton];
        [rightButtons addObject:rightButton];
        
        UIPanGestureRecognizer* recognizer = [self _gestureRecognizer];
        [rightButton addGestureRecognizer:recognizer];
        leftButton.userInteractionEnabled = NO;

//        ++_maxScore;
        ++tag;
    }
    
    _leftButtons = leftButtons;
    _rightButtons = [NSMutableArray arrayWithArray:[NSArray randomizedArrayFromArray:rightButtons]];
}


- (MatcherLabel*) _newLabelWithString:(NSString*) string side:(MatcherLabelOrientation) orientation {
    
//    UIFont* font = [UIFont fontWithName:@"HelveticaNeue" size:14];
//    UIColor* color = [UIColor blackColor];
//    
////    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
////    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
//    
//    NSDictionary* attributes = @{
//                                 NSFontAttributeName : font,
//                                 NSForegroundColorAttributeName : color,
////                                 NSParagraphStyleAttributeName : paragraph
//                                 };
//    
//    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];

    MatcherLabel* label = [[MatcherLabel alloc] init];
    label.string = string;
    label.orientation = orientation;
    [label createView];
    
    return label;
}



#pragma mark - Gesture Recognizer

- (UIPanGestureRecognizer*) _gestureRecognizer {
    
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
    
    return recognizer;
}


- (void) _handlePan:(UIPanGestureRecognizer*) recognizer {
    
    static CGPoint startPosition;
    
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
//            NSLog(@"began");
            
            _draggedView = (UIView<ReorderableViewProtocol>*)recognizer.view;
            _dragView = [self _createDragViewFromView:_draggedView];
            startPosition = [recognizer locationInView:self];
            
            [self addSubview:_dragView];
            
            [_draggedView setGhostAppearance];
            
            translate();
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


- (void) reorderWithDraggedView:(UIView*) draggedView dragView:(UIView*) dragView {
    
    UIView* view2 = [self viewUnderView:dragView];
    
    if (view2 != draggedView) {
        
        if ([self viewIsReorderable:view2]) {  // view under dragView is reorderableView
            
            [self swapView:draggedView withView:view2];
        }
    }
    else {
        
        NSLog(@"same in reorder");
    }
}


- (UIView*) viewUnderView:(UIView*) view {
    
    UIView* view2 = [self hitTest:view.center withEvent:nil];
    
    return view2;
}


- (BOOL) viewIsReorderable:(UIView*) view {
    
    return view.userInteractionEnabled && [view conformsToProtocol:@protocol(ReorderableViewProtocol)];
}


- (void) swapView:(UIView*) placedView withView:(UIView*) view {

    NSInteger index1 = [_rightButtons indexOfObject:view];
    NSInteger index2 = [_rightButtons indexOfObject:placedView];
    
    
    if (index1 == index2) {
        
        NSLog(@"SAME!");
        
        return;
    }

    
//    NSLog(@"swapping '%@' with '%@'", ((MatcherLabel*)view).string, ((MatcherLabel*)placedView).attributedString.string);
    
    
    [_rightButtons replaceObjectAtIndex:index1 withObject:placedView];
    [_rightButtons replaceObjectAtIndex:index2 withObject:view];
    
    

    [self setNeedsUpdateConstraints];
    
    animating = YES;
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
        [self layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        animating = NO;
        
//        [self reorderWithDraggedView:placedView dragView:_dragView];
    }];
}


- (MatcherLabel*) _createDragViewFromView:(MatcherLabel*) view {
    
    MatcherLabel* dragView = [[MatcherLabel alloc] init];
    
    // this is very important! if this is not set the views frame will get lost during layout pass because it does not get layouted via constraints but only by setting the frame
    
    dragView.translatesAutoresizingMaskIntoConstraints = YES;
    dragView.userInteractionEnabled = NO;
    dragView.string = view.string;
    dragView.orientation = view.orientation;
    [dragView createView];
    dragView.state = Selected;
    dragView.frame = view.frame;
    
    return dragView;
}


- (MatcherLabel*) _createCopyFromView:(MatcherLabel*) view {
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:view]];
}


- (BOOL) check {

    BOOL correct = YES;
    uint currentTag = 0;
    uint currentIndex = 0;
    NSInteger score = 0;
    
    self.userInteractionEnabled = NO;
    
    for (uint i = 0; i < _leftButtons.count; ++i) {
        
        MatcherLabel* leftLabel = [self viewWithTag:currentTag + 1000];
        MatcherLabel* rightLabel = _rightButtons[i];
        
        if (leftLabel.tag == rightLabel.tag - 1000) {
            
            rightLabel.state = Correct;
            score += SCORE_PER_PAIR;
        }
        else {
            
            rightLabel.state = Wrong;
            correct = NO;
        }
        
        ++currentTag;
        ++currentIndex;
        _maxScore += SCORE_PER_PAIR;
    }
    
    _scoreAfterCheck = score;
    
    return correct;
}


- (NSArray*) correctionStrings {
    
    NSMutableArray* strings = [NSMutableArray array];
    uint currentTag = 0;
    uint currentIndex = 0;
    
    for (uint i = 0; i < _leftButtons.count; ++i) {
        
        MatcherLabel* leftLabel = [self viewWithTag:currentTag + 1000];
        MatcherLabel* rightLabel = _rightButtons[i];
        
        if (leftLabel.tag != rightLabel.tag - 1000) {

            MatcherLabel* correctRightLabel = [self viewWithTag:currentTag + 2000];
            
            [strings addObject:leftLabel.string];
            [strings addObject:correctRightLabel.string];
        }
        
        ++currentTag;
        ++currentIndex;
    }
    
    return strings;
}



#pragma mark - Score

- (NSInteger) scoreAfterCheck {
    
    return _scoreAfterCheck;
}


- (NSInteger) maxScore {

    return _maxScore;
}



#pragma mark - Interface Builder

//- (void) prepareForInterfaceBuilder {
//    
//    [self initialize];
//    
//    self.pairs = @[
//                  @[@"Philip ... to buy the tickets." , @"is going"],
//                  @[@"They ... to sit on the open deck.", @"are going"],
//                  @[@"I ... to look at the Globe Theatre.", @"am going"]
//    ];
//    
//    [self createView];
//}


@end
