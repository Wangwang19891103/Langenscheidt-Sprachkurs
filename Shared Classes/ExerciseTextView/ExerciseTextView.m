//
//  ExerciseTextView.m
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 11.12.13.
//  Copyright (c) 2013 mobilinga. All rights reserved.
//

#import "ExerciseTextView.h"
#import "ExerciseTextViewTextLayer.h"
//#import "ExerciseGapTextField.h"
#import "UIView+Extensions.h"
#import "NSArray+Extensions.h"
#import "NSAttributedString+Extensions.h"
#import "macros.h"
#import "CGExtensions.h"
#import "NSMutableAttributedString+HTML.h"
#import "ExerciseTextField.h"


//#define LINE_SPACING                        2
//#define TEXTLAYER_ADJUSTMENT_Y              2
//#define TEXTFIELD_ADJUSTMENT_WIDTH          10



@implementation ExerciseTextView

//@synthesize attributedString;
@synthesize delegate;

@synthesize string;
@synthesize fontName;
@synthesize fontSize;
@synthesize fontColor;
@synthesize textLayerAdjustmentY;
@synthesize lineSpacing;
@synthesize textFieldHeight;
@synthesize textFieldAdjustmentWidth;
@synthesize textFieldBorderColor;
@synthesize textFieldBackgroundColor;
@synthesize textFieldBackgroundColorCorrect;
@synthesize textFieldBackgroundColorWrong;
@synthesize textFieldBorderColorSelected;

@synthesize inputType;
@synthesize generateSharedSolutions;


- (id) initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    
    [self initialize];
    return self;
}


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    [self initialize];
    return self;
}


- (void) initialize {
    
    _components = [NSMutableArray array];
    self.textFields = [NSMutableArray array];
//    self.backgroundColor = [UIColor clearColor];
    
    self.translatesAutoresizingMaskIntoConstraints = NO;

}


- (void) awakeFromNib {
    
    [super awakeFromNib];
}

//- (void) awakeFromNib {
//    
//    [super awakeFromNib];
//    
//    [self createView];
//}


//- (void) setAttributedString:(NSAttributedString *)p_attributedString {
//    
//    attributedString = p_attributedString;
//    
//    [self createView];
//}


- (void) createView {
    
    NSLog(@"createView");
    
    [self _createTextFieldVisualDictionary];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

//    NSLog(@"subview count: %d", self.subviews.count);
    
    
//    float textLayerAdjustmentY = [layout(self.class, @"TextLayerAdjustmentY") floatValue];
//    float lineSpacing = [layout(self.class, @"LineSpacing") floatValue];
    
    
    // scan attributed string into textlayers and textfields
    
//    NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
    
    NSDictionary* attributes = @{
                                 NSFontAttributeName : [UIFont fontWithName:self.fontName size:self.fontSize],
                                 NSForegroundColorAttributeName : self.fontColor
                                 };
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:self.string attributes:attributes];
    [attributedString parseHTML];
    
    [_components removeAllObjects];
    [self.textFields removeAllObjects];
    ExerciseTextScanner* scanner = [[ExerciseTextScanner alloc] init];
    scanner.delegate = self;
    [scanner scanAttributedString:attributedString];
    
    
    // Special case for DND: each text field only has one solution -> the solutions of all text fields together are available for any text field
    
    // check if the case stands
    
    if (self.generateSharedSolutions) {
    
        BOOL isDNDSpecialCase = YES;
        
        for (ExerciseTextField* textField in self.textFields) {
            
            if (textField.solutionStrings.count > 1) {
                
                isDNDSpecialCase = NO;
                break;
            }
        }
        
        if (isDNDSpecialCase) {
            
            for (ExerciseTextField* textField in self.textFields) {
                
                NSMutableArray* newSolutionStrings = [NSMutableArray array];
                
                [newSolutionStrings addObject:textField.solutionStrings[0]];
                
                for (ExerciseTextField* otherTextField in self.textFields) {
                    
                    if (otherTextField == textField) continue;
                    
                    [newSolutionStrings addObject:otherTextField.solutionStrings[0]];
                }
                
                textField.solutionStrings = newSolutionStrings;
            }
        }
    }
    
    // --
    
    
    // add components to layer / view
    
    // determine lineHeight
    
    float lineHeight = 0;
    
    for (uint i = 0; i < _components.count; ++i) {
        
        id component = _components[i];
        
        float height = 0;
        
        if ([component isKindOfClass:[CALayer class]]) {
            
            height = [(CALayer*)component bounds].size.height;
        }
        else if ([component isKindOfClass:[UIView class]]) {
            
            height = [(UIView*)component frame].size.height;
        }
//        else if ([component isKindOfClass:[NSArray class]]) {  // combine objects in array to combo view
//            
//            NSArray* comboArray = (NSArray*)component;
//            
//            NSLog(@"%@", comboArray);
//
//            UIView* comboView = [[UIView alloc] init];
//            float posX = 0;
//            float maxHeight = 0;
//            
//            for (id subComponent in comboArray) {
//                
//                if ([subComponent isKindOfClass:[ExerciseTextViewTextLayer class]]) {
//                    
//                    ExerciseTextViewTextLayer* layer = (ExerciseTextViewTextLayer*)subComponent;
//                    
//                    layer.position = CGPointMake(posX, textLayerAdjustmentY);
//                    [comboView.layer addSublayer:layer];
//                    posX += ceil(layer.bounds.size.width);
//                    maxHeight = MAX(maxHeight, layer.bounds.size.height);
//                }
//                else if ([subComponent isKindOfClass:[UIView class]]) {
//                    
//                    UIView* view = (UIView*)subComponent;
//                    
//                    [view setFrameOrigin:CGPointMake(posX, 0)];
//                    [comboView addSubview:view];
//                    posX += ceil(view.frame.size.width);
//                    maxHeight = MAX(maxHeight, view.frame.size.height);
//                }
//            }
//
//            [comboView setFrameSize:CGSizeMake(posX, maxHeight)];
//            
//            comboView.backgroundColor = [UIColor yellowColor];
//            
//            [_components replaceObjectAtIndex:i withObject:comboView];
//            
//            height = maxHeight;
//        }

        lineHeight = MAX(lineHeight, ceil(height));
    }
    
    
    
    float maxWidth = self.frame.size.width;
    float __block posX = 0;
    float __block posY = 0;
    float __block maxLineWidth = 0;
    BOOL __block lastLayerWasWhitespace = false;
    CALayer* textContainerLayer = [CALayer layer];
    
    void (^lineBreak)(void) = ^void (void) {

//        NSLog(@"lastLayerWasWhitespace: %d", lastLayerWasWhitespace);
        
        if (lastLayerWasWhitespace) {
            
            CALayer* lastLayer = [self.layer.sublayers lastObject];
            posX -= lastLayer.bounds.size.width;
            [lastLayer removeFromSuperlayer];
            lastLayerWasWhitespace = false;
        }
        
        maxLineWidth = MAX(maxLineWidth, posX);
        posX = 0;
        posY += lineHeight + lineSpacing;
    };
    
    BOOL (^layerFitsIntoCurrentLine)(CALayer*) = ^BOOL (CALayer* layer) {
    
        return (posX + layer.bounds.size.width <= maxWidth);
    };
    
    BOOL (^viewFitsIntoCurrentLine)(UIView*) = ^BOOL (UIView* view) {
        
        return (posX + view.frame.size.width <= maxWidth);
    };
    
    void (^addToLayer)(CALayer*) = ^void (CALayer* layer) {
      
        layer.position = CGPointMake(posX, posY + textLayerAdjustmentY);
        [self.layer addSublayer:layer];
        posX += ceil(layer.bounds.size.width);
    };
    
    void (^addToView)(UIView*) = ^void (UIView* view) {
        
        [view setFrameOrigin:CGPointMake(posX, posY)];
        [self addSubview:view];
        posX += ceil(view.frame.size.width);
    };
    
    
    for (uint i = 0; i < _components.count; ++i) {
        
        id component = _components[i];
        
        
        if ([component isKindOfClass:[ExerciseTextViewTextLayer class]]) {

            ExerciseTextViewTextLayer* textLayer = (ExerciseTextViewTextLayer*)component;
            
            if (textLayer.isWhitespace) {
                
                if (layerFitsIntoCurrentLine(textLayer)) {
                    
//                    NSLog(@"WHITESPACE");
                    
                    addToLayer(textLayer);
                    lastLayerWasWhitespace = true;
                }
            }
            else if (textLayer.isNewline) {
                
                lineBreak();
                lastLayerWasWhitespace = false;
            }
            else {
                
                if (!layerFitsIntoCurrentLine(textLayer)) {
                    
//                    NSLog(@"LINEBREAK");
                    
                    lineBreak();
                }
                
//                NSLog(@"WORD");
                
                addToLayer(textLayer);
                lastLayerWasWhitespace = false;
            }
        }
        else if ([component isKindOfClass:[UIView class]]) {
            
            UIView* view = (UIView*)component;
            
            if (!viewFitsIntoCurrentLine(view)) {
                
//                NSLog(@"LINEBREAK");
                
                lineBreak();
            }
            
//            NSLog(@"TEXTFIELD");
            
            addToView(view);
            lastLayerWasWhitespace = false;
        }
    }

    maxLineWidth = MAX(maxLineWidth, posX);

    [self setFrameHeight:posY + lineHeight];
//    [self setFrameWidth:maxLineWidth];
    textContainerLayer.bounds = CGRectMake(0, 0, maxLineWidth, posY + lineHeight);
    [self.layer addSublayer:textContainerLayer];
    
    UIView* selfView = self;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[selfView(==height)]"
                                                                options:0
                                                                metrics:@{@"height" : @(self.frame.size.height)}
                                                                   views:NSDictionaryOfVariableBindings(selfView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[selfView(==width)]"
                                                                 options:0
                                                                 metrics:@{@"width" : @(self.frame.size.width)}
                                                                   views:NSDictionaryOfVariableBindings(selfView)]];

    [self invalidateIntrinsicContentSize];
}


- (void) _createTextFieldVisualDictionary {
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    dict[@"notChecked"] = @{
                        @"backgroundColor" : self.textFieldBackgroundColor,
                        @"borderColor" : self.textFieldBorderColor,
                        @"borderColorSelected" : self.textFieldBorderColorSelected
                        };
    dict[@"correct"] = @{
                        @"backgroundColor" : self.textFieldBackgroundColorCorrect,
                        @"borderColor" : self.textFieldBorderColor,
                        @"borderColorSelected" : self.textFieldBorderColorSelected
                        };
    dict[@"wrong"] = @{
                        @"backgroundColor" : self.textFieldBackgroundColorWrong,
                        @"borderColor" : self.textFieldBorderColor,
                        @"borderColorSelected" : self.textFieldBorderColorSelected
                        };
    
    _textFieldVisualDictionary = dict;
}


#pragma mark - Add methods

- (void) addWordWithAttributedString:(NSAttributedString*) p_attributedString {
    
    ExerciseTextViewTextLayer* textLayer = [ExerciseTextViewTextLayer layer];
    textLayer.attributedString = p_attributedString;
    
    [_components addObject:textLayer];
}


- (void) addSinglePunctuationCharacterAttributedString:(NSAttributedString*) p_attributedString {

    ExerciseTextViewTextLayer* newTextLayer = [ExerciseTextViewTextLayer layer];
    newTextLayer.attributedString = p_attributedString;

    
    // go back to the latest layer which is not a whitespace layer (e.g. a gap or a word layer) and combine all layers up to that layer into a combo layer (e.g. an array object which is layouted later)
    
    
//    createMutableArray(combinedLayers);
    NSMutableArray* combinedLayers = [NSMutableArray array];
    
    [combinedLayers addObject:newTextLayer];
    
//    NSLog(@"%@", _components);
    
    for (NSInteger i = _components.count - 1; i >= 0; --i) {

        id object = _components[i];
        
        if ([object isKindOfClass:[ExerciseTextViewTextLayer class]]) {
            
            ExerciseTextViewTextLayer* textLayer = (ExerciseTextViewTextLayer*)object;
            
            if (textLayer.isNewline) break;  //TEST: does this work? how to handle newline layers?
            
            [combinedLayers addObject:textLayer];  // move layer from components into combo array
            [_components removeLastObject];
            
            if (!textLayer.isWhitespace) break;
        }
        else if ([object isKindOfClass:[UIView class]]) {
            
            [combinedLayers addObject:object];  // move gap view from components into combo array
            [_components removeLastObject];
            
            break;
        }
    }
    
    NSArray* comboArray = [combinedLayers reversedArray];
    UIView* comboView = [[UIView alloc] init];
    float posX = 0;
    float maxHeight = 0;
//    float textLayerAdjustmentY = [layout(self.class, @"TextLayerAdjustmentY") floatValue];
    
    for (id subComponent in comboArray) {
        
        if ([subComponent isKindOfClass:[ExerciseTextViewTextLayer class]]) {
            
            ExerciseTextViewTextLayer* layer = (ExerciseTextViewTextLayer*)subComponent;
            
            layer.position = CGPointMake(posX, textLayerAdjustmentY);
            [comboView.layer addSublayer:layer];
            posX += ceil(layer.bounds.size.width);
            maxHeight = MAX(maxHeight, layer.bounds.size.height);
        }
        else if ([subComponent isKindOfClass:[UIView class]]) {
            
            UIView* view = (UIView*)subComponent;
            
            [view setFrameOrigin:CGPointMake(posX, 0)];
            [comboView addSubview:view];
            posX += ceil(view.frame.size.width);
            maxHeight = MAX(maxHeight, view.frame.size.height);
        }
    }
    
    [comboView setFrameSize:CGSizeMake(posX, maxHeight)];
    
//    comboView.backgroundColor = [UIColor yellowColor];

    [_components addObject:comboView];
}


- (void) addWhitespaceWithAttributedString:(NSAttributedString*) p_attributedString {

    ExerciseTextViewTextLayer* textLayer = [ExerciseTextViewTextLayer layer];
    textLayer.attributedString = p_attributedString;
    textLayer.isWhitespace = true;
    
    [_components addObject:textLayer];
}


- (void) addNewline {
    
    ExerciseTextViewTextLayer* textLayer = [ExerciseTextViewTextLayer layer];
    textLayer.isNewline = true;
    
    [_components addObject:textLayer];
}


- (void) addGapTextFieldWithAttributedString:(NSAttributedString*) p_attributedString {

    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:p_attributedString];
    
    // code for rendering different states in Interface Builder

#if TARGET_INTERFACE_BUILDER
    
    ExerciseControlSolutionState debugSolutionState = ExerciseControlSolutionStateNotChecked;
    
    if ([[attributedString.string substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"@c"]) {
        
        debugSolutionState = ExerciseControlSolutionStateCorrect;
        [attributedString replaceCharactersInRange:NSMakeRange(0, 2) withString:@""];
    }
    else if ([[attributedString.string substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"@w"]) {
        
        debugSolutionState = ExerciseControlSolutionStateWrong;
        [attributedString replaceCharactersInRange:NSMakeRange(0, 2) withString:@""];
    }
    
#endif
    
    // ---

    NSArray* solutions = [attributedString componentsSeperatedByString:@"|"];
    CGSize maxSize = CGSizeZero;
    createMutableArray(solutionStrings);
    
    for (NSAttributedString* solution in solutions) {

        CGSize size = [solution boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        maxSize = CGSizeMax(maxSize, size);
        
        [solutionStrings addObject:solution.string];
    }
    
//    ExerciseGapTextField* textField = [[ExerciseGapTextField alloc] initWithFrame:CGRectMake(0, 0, maxSize.width + TEXTFIELD_ADJUSTMENT_WIDTH, [ExerciseGapTextField preferredHeight])];
    
//    textField.solutions = solutionStrings;
    
    ExerciseTextField* textField = [[ExerciseTextField alloc] initWithFrame:CGRectMake(0, 0, maxSize.width + self.textFieldAdjustmentWidth, textFieldHeight)];
//    textField.layer.borderColor = self.textFieldBorderColor.CGColor;
    textField.solutionStrings = solutionStrings;
    textField.layer.borderWidth = 1;
    textField.font = [UIFont fontWithName:self.fontName size:self.fontSize];
//    textField.backgroundColor = self.textFieldBackgroundColor;
    textField.stateVisualDictionary = _textFieldVisualDictionary;
    textField.inputType = inputType;
    textField.scrollContainerView = self;
    
#if TARGET_INTERFACE_BUILDER
    
    textField.text = solutionStrings[0];
    textField.solutionState = debugSolutionState;
    
#endif
    
    [_components addObject:textField];
    [self.textFields addObject:textField];
}



#pragma mark - Delegate

- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanWordString:(NSAttributedString *)p_attributedString {
    
//    NSLog(@"wordString: \"%@\"", p_attributedString.string);
    
    [self addWordWithAttributedString:p_attributedString];
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanPunctuationString:(NSAttributedString *)p_attributedString {
    
//    NSLog(@"punctuationString: \"%@\"", p_attributedString.string);
    
    // detect single character (e.g. detecting punctuation at end of a sentence)
    
    if (p_attributedString.string.length == 1) {
        
        [self addSinglePunctuationCharacterAttributedString:p_attributedString];
    }
    else {
        
        [self addWordWithAttributedString:p_attributedString];
    }
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanWhitespaceString:(NSAttributedString *)p_attributedString {
    
//    NSLog(@"whitespaceString: \"%@\"", p_attributedString.string);
    
    [self addWhitespaceWithAttributedString:p_attributedString];
}


- (void) exerciseTextScanner:(ExerciseTextScanner *)scanner didScanGapWithString:(NSAttributedString *)p_attributedString {
    
//    NSLog(@"gapString: \"%@\"", p_attributedString.string);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(exerciseTextView:viewForGapString:)]) {
        
        UIView* view = [self.delegate exerciseTextView:self viewForGapString:p_attributedString.string];
        
        [_components addObject:view];
    }
    else {

        [self addGapTextFieldWithAttributedString:p_attributedString];
    }
}


- (void) exerciseTextScannerDidScanNewline:(ExerciseTextScanner *)scanner {
    
//    NSLog(@"newline");
    
    [self addNewline];
}







- (CGSize) intrinsicContentSize {
    
//    return self.frame.size;
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}




#pragma mark - Interface Builder

- (void) prepareForInterfaceBuilder {
    
    [self createView];
}




@end
