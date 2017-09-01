//
//  ExerciseDragAndDropView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "SCRView.h"
#import "NSMutableAttributedString+HTML.h"
#import "ExerciseReorderableLabel.h"
#import "NSArray+Extensions.h"
#import "SCRLabel.h"



#define SCORE_PER_LABEL         1
#define SCORE_PER_3_6   3
#define SCORE_PER_7_MORE    4



@implementation SCRView

@synthesize string;
@synthesize fontName;
@synthesize fontSize;
@synthesize fontColor;
@dynamic horizontalSpacing;
@dynamic verticalSpacing;
@synthesize buttonMargins;
@synthesize fixedLabelBackgroundColor;
@synthesize movableLabelBackgroundColor;
@synthesize ghostLabelBackgroundColor;


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
    
    [super initialize];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    _components = [NSMutableArray array];
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
}


#pragma mark - IB

- (void) prepareForInterfaceBuilder {
    
    [self initialize];
    
    [self createView];
}



#pragma mark - View, Layout, Constraints

- (void) didMoveToSuperview {
    
    NSLog(@"ExerciseDragAndDropView - didMoveToSuperview");
    
    [super didMoveToSuperview];
    
    if (self.superview) {
        
    }
}


- (void) createView {
    
    NSLog(@"ExerciseDragAndDropView - createView");
    
    [self _parseString];

    [self _scrambleComponents];

    [self _addComponentsToView];
}


- (void) _scrambleComponents {
    
    _correctOrder = [NSArray arrayWithArray:_components];
    _components = [NSMutableArray arrayWithArray:[NSArray randomizedArrayFromArray:_components]];
    
    // put prefixes back at the original position
    
    for (uint i = 0; i < _correctOrder.count; ++i) {
        
        SCRLabel* label = _correctOrder[i];
        
        if (label.state == Immovable) {
        
            NSInteger index = [_components indexOfObject:label];
            [_components removeObjectAtIndex:index];
            [_components insertObject:label atIndex:i];
        }
    }
}


- (void) _addComponentsToView {
    
    _maxScore = 0;
    
    for (UIView* view in _components) {
        
        [self addSubview:view];
    }
    
    if (_correctOrder.count > 2 || _correctOrder.count < 7){
        
        _maxScore += SCORE_PER_3_6;
    }
    else if (_correctOrder.count > 6){
        
        _maxScore += SCORE_PER_7_MORE;
    }
    else{
        
        _maxScore += SCORE_PER_LABEL;
    }
}


- (void) updateConstraints {

    // do something here
    
    [super updateConstraints];
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}



#pragma mark - String parsing

- (void) _parseString {
    
    NSDictionary* attributes = @{
                                 NSFontAttributeName : [UIFont fontWithName:self.fontName size:self.fontSize],
                                 NSForegroundColorAttributeName : self.fontColor
                                 };
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:self.string attributes:attributes];
    [attributedString parseHTML];
    
    [_components removeAllObjects];
    _scanner = [[ExerciseTextScanner alloc] init];
    _scanner.delegate = self;
    [_scanner scanAttributedString:attributedString];
}


- (void) _addLabelToComponentsWithAttributedString:(NSAttributedString*) attributedString {
    
    CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    textRect.size.width += 2 * self.buttonMargins;
    textRect.size.height += 2 * self.buttonMargins;
    
//    UILabel* label = [[UILabel alloc] init];
//    [label setAttributedText:attributedString];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = self.fixedLabelBackgroundColor;
//    
//    label.translatesAutoresizingMaskIntoConstraints = NO;

    SCRLabel* label = [[SCRLabel alloc] initWithString:attributedString.string];
    label.state = Immovable;
    [label createView];
    
    label.userInteractionEnabled = YES;  // important for finding views next to other views with hitTest
    
//    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(width)]" options:0 metrics:@{@"width" : @(ceilf(textRect.size.width))} views:NSDictionaryOfVariableBindings(label)]];
//    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(height)]" options:0 metrics:@{@"height" : @(ceilf(textRect.size.height))} views:NSDictionaryOfVariableBindings(label)]];
    
    [_components addObject:label];
}


- (void) _addDNDButtonToComponentsWithAttributedString:(NSAttributedString*) attributedString {
    
    CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];

    textRect.size.width += 2 * self.buttonMargins;
    textRect.size.height += 2 * self.buttonMargins;
    
//    ExerciseReorderableLabel* label = [[ExerciseReorderableLabel alloc] init];
//    [label setAttributedText:attributedString];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.normalBackgroundColor = self.movableLabelBackgroundColor;
//    label.ghostBackgroundColor = self.ghostLabelBackgroundColor;
//    
//    label.translatesAutoresizingMaskIntoConstraints = NO;

    SCRLabel* label = [[SCRLabel alloc] initWithString:attributedString.string];
    [label createView];
    
    label.userInteractionEnabled = YES;
    
//    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(width)]" options:0 metrics:@{@"width" : @(ceilf(textRect.size.width))} views:NSDictionaryOfVariableBindings(label)]];
//    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(height)]" options:0 metrics:@{@"height" : @(ceilf(textRect.size.height))} views:NSDictionaryOfVariableBindings(label)]];
    
    [_components addObject:label];
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanWordString:(NSAttributedString *)attributedString {
    
    [self _addLabelToComponentsWithAttributedString:attributedString];
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanGapWithString:(NSAttributedString *)attributedString {
    
    [self _addDNDButtonToComponentsWithAttributedString:attributedString];
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanWhitespaceString:(NSAttributedString *)attributedString {
    
    // do nothing
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanPunctuationString:(NSAttributedString *)attributedString {
    
    [self _addLabelToComponentsWithAttributedString:attributedString];
}



- (UIView<ReorderableViewProtocol>*) _createDragViewFromView:(UIView<ReorderableViewProtocol>*) view {

    SCRLabel* label = (SCRLabel*)view;
    SCRLabel* copy = [[SCRLabel alloc] initWithString:label.string];
    copy.state = Dragged;
    [copy createView];

    copy.bounds = label.bounds;
    copy.translatesAutoresizingMaskIntoConstraints = YES;
    copy.userInteractionEnabled = NO;

    return copy;
}


- (BOOL) viewIsMovable:(UIView *)view {
    
    if ([view isKindOfClass:[SCRLabel class]]) {
        
        SCRLabel* label = (SCRLabel*)view;
        
        if (label.state != Immovable) {
            
            return YES;
        }
        else return NO;
    }
    else return NO;
}


- (BOOL) viewIsReorderable:(UIView *)view {
    
    return [self viewIsMovable:view];
}




#pragma mark - Check

- (BOOL) check {

    BOOL correct = YES;
    uint subviewIndex = 0;
    NSInteger score = 0;
    
    self.userInteractionEnabled = NO;
    
    NSLog(@"_correctOrder.count is : %ld", (long)_correctOrder.count);
    
    for (uint i = 0; i < _correctOrder.count; ++i) {
        
        SCRLabel* label = _correctOrder[i];

        SCRLabel* subview = nil;
        
        while (!subview && subviewIndex < self.subviews.count) {
            
            if ([self.subviews[subviewIndex] isKindOfClass:[SCRLabel class]]) {
                
                subview = self.subviews[subviewIndex];
            }
            
            ++subviewIndex;
        }
        

        BOOL same = [label.string isEqualToString:subview.string];
        
        if (!same) {
            
            label.state = Wrong;
            correct = NO;
        }
        else {
            
            label.state = Correct;
            
            // logical dividing scrabled sentences element. To do this, use _correctOrder.count(int).
            if (  i == _correctOrder.count - 1){
                
                if (_correctOrder.count > 2 || _correctOrder.count < 7){
                    
                    score = SCORE_PER_3_6;
                }
                else if (_correctOrder.count > 6){
                    
                    score = SCORE_PER_7_MORE;
                }
                else{
                    
                    score = SCORE_PER_LABEL;
                }
                
            }
        }
    }
    
    _scoreAfterCheck = score;
    
    return correct;
}


- (NSString*) correctionString {
    
    NSMutableArray* strings = [NSMutableArray array];
    
    for (SCRLabel* label in _correctOrder) {
        
        [strings addObject:label.string];
    }
    
    return [strings componentsJoinedByString:@" | "];
}



#pragma mark - Test

- (void) remove:(UIButton*) sender {
    
    NSLog(@"remove");
    
    [sender removeFromSuperview];
    
    [self setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        [self layoutIfNeeded];
    }];
}



@end
