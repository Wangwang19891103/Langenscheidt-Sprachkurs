//
//  ExerciseCorrectionView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExerciseCorrectionView.h"
#import "NSAttributedString+HTML.h"
#import "NSAttributedString+Extensions.h"


#define FONT_NORMAL     @"HelveticaNeue"
#define FONT_BOLD       @"HelveticaNeue-Bold"
#define FONT_SIZE       15.0f


@implementation ExerciseCorrectionView

@synthesize strings;
@synthesize textContainer;
@synthesize tabular;


- (id) init {
    
    self = [[UINib nibWithNibName:@"ExerciseCorrectionView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil][0];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    return self;
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


- (void) createView {
    
    [self _createAttributes];
    
    
//    self.textContainer.highlight = YES;
    
    if (!self.tabular) {
    
        for (NSString* string in self.strings) {
            
            ExerciseTextScanner* scanner = [[ExerciseTextScanner alloc] init];
            scanner.delegate = self;
            NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string];
            attributedString = [attributedString attributedStringWithParsedHTML];
            _textString = [[NSMutableAttributedString alloc] init];
            [scanner scanAttributedString:attributedString];
            
            UILabel* label = [[UILabel alloc] init];
            label.translatesAutoresizingMaskIntoConstraints = NO;
            label.attributedText = _textString;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            [self.textContainer addSubview:label];
        }
    }
    else {
        
        uint index = 0;
        
        while (index < self.strings.count) {

            NSMutableArray* labels = [NSMutableArray array];
            
            for (uint i = 0; i < 2; ++i) {

                NSString* string = self.strings[index];
            
                ExerciseTextScanner* scanner = [[ExerciseTextScanner alloc] init];
                scanner.delegate = self;
                NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:string];
                attributedString = [attributedString attributedStringWithParsedHTML];
                _textString = [[NSMutableAttributedString alloc] init];
                [scanner scanAttributedString:attributedString];

                UILabel* label = [[UILabel alloc] init];
                label.translatesAutoresizingMaskIntoConstraints = NO;
                label.attributedText = _textString;
                label.numberOfLines = 0;
                label.lineBreakMode = NSLineBreakByWordWrapping;

                [labels addObject:label];
                
                ++index;
            }
            
            UIView* lineContainer = [[UIView alloc] init];
            lineContainer.translatesAutoresizingMaskIntoConstraints = NO;

            UILabel* leftLabel = labels[0];
            UILabel* rightLabel = labels[1];
            
            [lineContainer addSubview:leftLabel];
            [lineContainer addSubview:rightLabel];
            
            CGFloat spacing = 20.0;
            
            [lineContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[leftLabel(rightLabel)]-(spacing)-[rightLabel]-0-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"spacing" : @(spacing)} views:NSDictionaryOfVariableBindings(leftLabel, rightLabel)]];
            [lineContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[leftLabel]-(>=0)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(leftLabel)]];
            [lineContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[rightLabel]-(>=0)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(rightLabel)]];
            
            [self.textContainer addSubview:lineContainer];
        }
    }
}


- (void) updateConstraints {

//    [self.textContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_label]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_label)]];
//    [self.textContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_label]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_label)]];

    [super updateConstraints];
}


- (void) _createAttributes {
    
    UIFont* normalFont = [UIFont fontWithName:FONT_NORMAL size:FONT_SIZE];
    UIFont* boldFont = [UIFont fontWithName:FONT_BOLD size:FONT_SIZE];
    
    _normalAttributes = @{
                          NSFontAttributeName : normalFont
                          };
    _boldAttributes = @{
                        NSFontAttributeName : boldFont
                        };
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanWordString:(NSAttributedString *)attributedString {
    
    [self _appendNormalTextWithString:attributedString.string];
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanWhitespaceString:(NSAttributedString *)attributedString {
    
    [self _appendNormalTextWithString:attributedString.string];
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanPunctuationString:(NSAttributedString *)attributedString {
    
    [self _appendNormalTextWithString:attributedString.string];
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanGapWithString:(NSAttributedString *)attributedString {
    
    NSArray* solutions = [attributedString componentsSeperatedByString:@"|"];
    NSAttributedString* solution = solutions[0];
    
    [self _appendBoldTextWithString:solution.string];
}


- (void) _appendNormalTextWithString:(NSString*) p_string {
    
    [_textString appendAttributedString:[[NSAttributedString alloc] initWithString:p_string attributes:_normalAttributes]];
}


- (void) _appendBoldTextWithString:(NSString*) p_string {
    
    [_textString appendAttributedString:[[NSAttributedString alloc] initWithString:p_string attributes:_boldAttributes]];
}

@end
