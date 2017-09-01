//
//  SnakeView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "SnakeView.h"
#import "NSArray+Extensions.h"
#import "UIView+RemoveConstraints.h"
#import "CGExtensions.h"
#import "SnakeUnderlayItem.h"


#define NUMBER_OF_RANDOM_LETTERS_FRONT              NSMakeRange(4, 6)
#define NUMBER_OF_RANDOM_LETTERS_BACK               NSMakeRange(4, 6)

#define BUTTON_SIZE         CGSizeMake(33, 37)

#define SPACING_H   4
#define SPACING_V   4

#define NUMBER_OF_LETTERS_PER_ROW                   6
#define NUMBER_OF_LETTERS_BETWEEN_ROWS              1

#define TOTAL_NUMBERS_OF_LETTERS            ((NUMBER_OF_LETTERS_PER_ROW - 1) + NUMBER_OF_LETTERS_BETWEEN_ROWS + NUMBER_OF_LETTERS_PER_ROW + NUMBER_OF_LETTERS_BETWEEN_ROWS + (NUMBER_OF_LETTERS_PER_ROW - 1))


#define SCORE_FOR_CORRECT_ANSWER            3


#define UNDERLAY_COLOR      [UIColor colorWithWhite:0.87 alpha:1.0]



typedef NS_ENUM(NSInteger, SnakeLayoutDirection) { Right, Down1, Left, Down2 };




@implementation SnakeView


@synthesize string;
@synthesize prefix;



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
    self.backgroundColor = [UIColor clearColor];
    _randomLetters = @"abcdefghijklmnopqrstuvwxyz";
    _maxScore = SCORE_FOR_CORRECT_ANSWER;
}



#pragma mark - View, Layout, Constraints

- (void) createView {
    
    [self _createInnerView];
    
//    [self _createUnderlayView];
    
    [self _createLetters];
    
    [self addGestureRecognizer:[self _createPanGestureRecognizer]];
    [self addGestureRecognizer:[self _createTapGestureRecognizer]];
}


- (void) _createInnerView {
    
    _innerView = [[UIView alloc] init];
    _innerView.backgroundColor = [UIColor clearColor];
    _innerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_innerView];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_innerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_innerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_innerView)]];
}


//- (void) _createUnderlayView {
//    
//    _underlayView = [[UIView alloc] init];
//    _underlayView.backgroundColor = [UIColor clearColor];
//    _underlayView.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [self insertSubview:_underlayView belowSubview:_innerView];
//    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_underlayView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
//    
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_underlayView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_underlayView)]];
//    
//}


- (void) _createLetters {
    
    NSMutableArray* buttons = [NSMutableArray array];
    
//    NSInteger numberOfRandomLettersFront = NUMBER_OF_RANDOM_LETTERS_FRONT.location + (arc4random() % NUMBER_OF_RANDOM_LETTERS_FRONT.length);
//    NSInteger numberOfRandomLettersBack = NUMBER_OF_RANDOM_LETTERS_BACK.location + (arc4random() % NUMBER_OF_RANDOM_LETTERS_BACK.length);

    
    NSInteger totalLetterCount = TOTAL_NUMBERS_OF_LETTERS;
    NSInteger solutionLetterCount = self.string.length;
    NSInteger randomLetterCount = ABS(totalLetterCount - solutionLetterCount);
    NSInteger frontLetterCount = arc4random() % (randomLetterCount + 1);
    
    if (self.prefix) {
        
        frontLetterCount = MAX(frontLetterCount, self.prefix.length);
    }
    
    NSInteger backLetterCount = randomLetterCount - frontLetterCount;
    
    
    // prefix letters
    
    if (self.prefix) {

        for (uint i = 0; i < self.prefix.length; ++i) {
            
            NSString* substring = [self.prefix substringWithRange:NSMakeRange(i, 1)];
            
            SnakeLabel* label = [self _createLabelWithString:substring];
            label.correctAnswer = NO;
            label.userInteractionEnabled = NO;
            label.state = Prefix;
            
            [buttons addObject:label];
        }
        
        frontLetterCount -= self.prefix.length;
    }
    
    
    // random letters front
    
    for (uint i = 0; i < frontLetterCount; ++i) {
        
        uint randomIndex = arc4random() % _randomLetters.length;
        NSString* randomCharString = [_randomLetters substringWithRange:NSMakeRange(randomIndex, 1)];
        
        SnakeLabel* label = [self _createLabelWithString:randomCharString];
        
        [buttons addObject:label];
    }
    
    
    // solution letters
    
    for (uint i = 0; i < self.string.length; ++i) {
        
        NSString* substring = [self.string substringWithRange:NSMakeRange(i, 1)];
        
        SnakeLabel* label = [self _createLabelWithString:substring];
        label.correctAnswer = YES;
        
        [buttons addObject:label];
    }
    
    
    // random letters back
    
    for (uint i = 0; i < backLetterCount; ++i) {
        
        uint randomIndex = arc4random() % _randomLetters.length;
        NSString* randomCharString = [_randomLetters substringWithRange:NSMakeRange(randomIndex, 1)];
        
        SnakeLabel* label = [self _createLabelWithString:randomCharString];
        
        [buttons addObject:label];
    }

    
    // add buttons to view
    
    for (UIView* view in buttons) {
        
        [_innerView addSubview:view];
        
        [self _createUnderlayItemForButton:view];
    }
    
    
    _buttons = buttons;
}


- (void) _createUnderlayItemForButton:(UIView*) button {
    
    SnakeUnderlayItem* item = [[SnakeUnderlayItem alloc] init];
    item.translatesAutoresizingMaskIntoConstraints = NO;
    item.color = UNDERLAY_COLOR;
    item.cornerRadius = 15;
    
    CGFloat border = 10;
    
    [_innerView insertSubview:item atIndex:0];

    [_innerView addConstraint:[NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeTop multiplier:1.0 constant:-border]];

    [_innerView addConstraint:[NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-border]];

    [_innerView addConstraint:[NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeBottom multiplier:1.0 constant:border]];

    [_innerView addConstraint:[NSLayoutConstraint constraintWithItem:item attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeRight multiplier:1.0 constant:border]];
}


- (SnakeLabel*) _createLabelWithString:(NSString*) theString {
    
    SnakeLabel* label = [[SnakeLabel alloc] initWithString:theString];
    label.userInteractionEnabled = YES;
    
    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(width)]" options:0 metrics:@{@"width" : @(BUTTON_SIZE.width)} views:NSDictionaryOfVariableBindings(label)]];

    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(height)]" options:0 metrics:@{@"height" : @(BUTTON_SIZE.height)} views:NSDictionaryOfVariableBindings(label)]];

    [label createView];
    
    return label;
}


- (void) layoutSubviews {
    
    NSLog(@"layoutSubviews");
    
    [super layoutSubviews];
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



#pragma mark - View layout logic

- (void) _arrangeSubviews {
    
    SnakeLayoutDirection direction = Right;
    
    uint labelIndex = 0;
    SnakeLabel* previousLabel = nil;
    BOOL firstRow = YES;
    
    for (UIView* view in _buttons) {
        
        [self removeConstraintsAffectingSubview:view];
    }

    
    while (labelIndex < _buttons.count) {
    
        SnakeLabel* label = _buttons[labelIndex];
        
        [self removeConstraintsAffectingSubview:label];
        
//        [self _insertFirstLabelIndex:&labelIndex];
        
        [self _arrangeLabelsWithDirection:direction index:&labelIndex previousLabel:&previousLabel firstRow:&firstRow];
        
        direction = (direction + 1) % 4;  //TEST
    }
    
    if (previousLabel) {
        
        [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousLabel]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(previousLabel)]];
    }
}


//- (void) _insertFirstLabelIndex:(uint*) index {
//    
//    SnakeLabel* label = _buttons[0];
//    
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[label]" options:0 metrics:@{@"spacing" : @()} views:NSDictionaryOfVariableBindings(label)]];
//    
//    *index = 2;
//}


- (void) _arrangeLabelsWithDirection:(SnakeLayoutDirection) direction index:(uint*) index previousLabel:(SnakeLabel**) previousLabel firstRow:(BOOL*) firstRow {
    
    if (direction == Left || direction == Right) {
        
        [self _horizontallyArrangeLabelsWithDirection:direction withIndex:index previousLabel:previousLabel firstRow:firstRow];
    }
    else if (direction == Down1 || direction == Down2) {
        
        [self _verticallyArrangeLabelsWithIndex:index previousLabel:previousLabel];
    }
}


- (void) _horizontallyArrangeLabelsWithDirection:(SnakeLayoutDirection) direction withIndex:(uint*) index previousLabel:(SnakeLabel**) previousLabel firstRow:(BOOL*) firstRow {
    
    uint col = 0;
    BOOL firstInRow = YES;

    if (*firstRow) {
        
        col = 1;
    }
    
    while (*index < _buttons.count && col < NUMBER_OF_LETTERS_PER_ROW) {
        
        SnakeLabel* label = _buttons[*index];
        
        if (firstInRow) {
            
//            NSLog(@"firstInRow");
            
            [self _verticallyConnectLabel:label toLabel:*previousLabel];
        }
        else {
            
            [self _horizontallyConnectLabel:label toLabel:*previousLabel direction:direction];
        }
        
        if (!*previousLabel) {  // first label ever -> connect to left side of superview
            
//            [self _horizontallyConnectLabel:label toLabel:nil direction:direction];
            [self _insertFirstLabel:label];
        }
        
        if (direction == Right && col == NUMBER_OF_LETTERS_PER_ROW - 1) {  // last in row (if Right)
            
            [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(label)]];
        }
        
        *previousLabel = label;
        ++col;
        firstInRow = NO;
        ++*index;
    }
    
    *firstRow = NO;
}


- (void) _insertFirstLabel:(SnakeLabel*) label {
    
    CGFloat spacing = BUTTON_SIZE.width + SPACING_H;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[label]" options:0 metrics:@{@"spacing" : @(spacing)} views:NSDictionaryOfVariableBindings(label)]];
}


- (void) _verticallyArrangeLabelsWithIndex:(uint*) index previousLabel:(SnakeLabel**) previousLabel {
    
    uint row = 0;
    
    while (*index < _buttons.count && row < NUMBER_OF_LETTERS_BETWEEN_ROWS) {
        
        SnakeLabel* label = _buttons[*index];
        
        [self _verticallyConnectLabel:label toLabel:*previousLabel];
        
        *previousLabel = label;
        ++row;
        ++*index;
    }
}


- (void) _horizontallyConnectLabel:(SnakeLabel*) label1 toLabel:(SnakeLabel*) label2 direction:(SnakeLayoutDirection) direction {
    
//    NSLog(@"H: '%@' to '%@'", label1.attributedText.string, label2.attributedText.string);
    
    NSString* formatString = nil;
    NSDictionary* views = nil;
    
    if (label2) {

        formatString = (direction == Right) ? @"H:[label2]-(spacing)-[label1]" : @"H:[label1]-(spacing)-[label2]";
        views = NSDictionaryOfVariableBindings(label1, label2);
    }
    else {
        
        formatString = @"H:|-[label1]";
        views = NSDictionaryOfVariableBindings(label1);
    }
    
    [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:NSLayoutFormatAlignAllTop metrics:@{@"spacing" : @(SPACING_H)} views:views]];
}


- (void) _verticallyConnectLabel:(SnakeLabel*) label1 toLabel:(SnakeLabel*) label2 {

//    NSLog(@"V: '%@' to '%@'", label1.attributedText.string, label2.attributedText.string);

    NSString* formatString = nil;
    NSDictionary* views = nil;
    
    if (label2) {
        
        formatString = @"V:[label2]-(spacing)-[label1]";
        views = NSDictionaryOfVariableBindings(label1, label2);
    }
    else {
        
        formatString = @"V:|-0-[label1]";
        views = NSDictionaryOfVariableBindings(label1);
    }
    
    [_innerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:formatString options:NSLayoutFormatAlignAllRight metrics:@{@"spacing" : @(SPACING_V)} views:views]];
}



#pragma mark - Gesture recognizers

- (UILongPressGestureRecognizer*) _createPanGestureRecognizer {
    
    // using long press unstead of pan because there is no delay in pixels moved before recognition
    
    UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePan:)];
    recognizer.minimumPressDuration = 0.1;
    
    return recognizer;
}


- (void) _handlePan:(UILongPressGestureRecognizer*) recognizer {

    static enum { Select, Deselect } mode;

    
    // inline blocks
    
    SnakeLabel*(^labelAtTouchPosition)(void) = ^SnakeLabel*(void) {

        CGPoint position = [recognizer locationInView:_innerView];
        SnakeLabel* label = [self _labelAtPosition:position];
        
        return label;
    };
    
    void(^switchSelected)(SnakeLabel*) = ^void(SnakeLabel* label) {
      
        if (mode == Select && label.state == Normal) {
            
            label.state = Selected;
        }
        else if (mode == Deselect && label.state == Selected) {
            
            label.state = Normal;
        }
    };
    
    
    switch (recognizer.state) {

        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"began");
            
            SnakeLabel* label = labelAtTouchPosition();
            
            if (label) {
                
                mode = (label.state == Selected) ? Deselect : Select;
                
                switchSelected(label);
            }
            else {
                
                recognizer.enabled = NO;
            }
        }
            break;
        
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"changed");
            
            SnakeLabel* label = labelAtTouchPosition();

            if (label) {
                
                switchSelected(label);
            }
        }
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"ended");
        }
            break;
            
        case UIGestureRecognizerStateCancelled:
        {
            NSLog(@"cancelled");
            
            recognizer.enabled = YES;
        }
            break;
            
        default:
            break;
    }
}


- (SnakeLabel*) _labelAtPosition:(CGPoint) position {

    UIView* view = [_innerView hitTest:position withEvent:nil];
    
    if ([self _viewIsLabel:view]) {
        
        return (SnakeLabel*)view;
    }
    else return nil;
}


- (BOOL) _viewIsLabel:(UIView*) view {
    
    return [view isKindOfClass:[SnakeLabel class]];
}


- (UITapGestureRecognizer*) _createTapGestureRecognizer {
    
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
    
    return recognizer;
}


- (void) _handleTap:(UITapGestureRecognizer*) recognizer {
    
    CGPoint position = [recognizer locationInView:_innerView];
    
    SnakeLabel* label = [self _labelAtPosition:position];
    
    if (label) {
        
        if (label.state == Normal) {
            
            label.state = Selected;
        }
        else if (label.state == Selected) {
            
            label.state = Normal;
        }
    }
}


- (BOOL) check {
    
    BOOL correct = YES;
    NSInteger score = 0;
    
    self.userInteractionEnabled = NO;
    
    
    for (SnakeLabel* label in _buttons) {
        
        if (label.correctAnswer && label.state == Selected) {
            
            label.state = Correct;
        }
        else if (label.correctAnswer && label.state == Normal) {
            
            label.state = Wrong;
            correct = NO;
        }
        else if (!label.correctAnswer && label.state == Selected) {
            
            label.state = Wrong;
            correct = NO;
        }
    }
    
    if (correct) {
        
        score = SCORE_FOR_CORRECT_ANSWER;
    }
    
    _scoreAfterCheck = score;

    
    return correct;
}


@end












