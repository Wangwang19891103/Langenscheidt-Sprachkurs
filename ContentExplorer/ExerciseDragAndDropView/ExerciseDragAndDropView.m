//
//  ExerciseDragAndDropView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ExerciseDragAndDropView.h"
#import "NSMutableAttributedString+HTML.h"
#import "ExerciseReorderableLabel.h"
#import "NSArray+Extensions.h"


@implementation ExerciseDragAndDropView

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
    
    _components = [NSMutableArray arrayWithArray:[NSArray randomizedArrayFromArray:_components]];
}


- (void) _addComponentsToView {
    
    for (UIView* view in _components) {
        
        [self addSubview:view];
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
    
    UILabel* label = [[UILabel alloc] init];
    [label setAttributedText:attributedString];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = self.fixedLabelBackgroundColor;
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    label.userInteractionEnabled = YES;  // important for finding views next to other views with hitTest
    
    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(width)]" options:0 metrics:@{@"width" : @(ceilf(textRect.size.width))} views:NSDictionaryOfVariableBindings(label)]];
    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(height)]" options:0 metrics:@{@"height" : @(ceilf(textRect.size.height))} views:NSDictionaryOfVariableBindings(label)]];
    
    [_components addObject:label];
}


- (void) _addDNDButtonToComponentsWithAttributedString:(NSAttributedString*) attributedString {
    
    CGRect textRect = [attributedString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil];

    textRect.size.width += 2 * self.buttonMargins;
    textRect.size.height += 2 * self.buttonMargins;
    
    ExerciseReorderableLabel* label = [[ExerciseReorderableLabel alloc] init];
    [label setAttributedText:attributedString];
    label.textAlignment = NSTextAlignmentCenter;
    label.normalBackgroundColor = self.movableLabelBackgroundColor;
    label.ghostBackgroundColor = self.ghostLabelBackgroundColor;
    
    label.translatesAutoresizingMaskIntoConstraints = NO;

    label.userInteractionEnabled = YES;
    
    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(width)]" options:0 metrics:@{@"width" : @(ceilf(textRect.size.width))} views:NSDictionaryOfVariableBindings(label)]];
    [label addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(height)]" options:0 metrics:@{@"height" : @(ceilf(textRect.size.height))} views:NSDictionaryOfVariableBindings(label)]];
    
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
