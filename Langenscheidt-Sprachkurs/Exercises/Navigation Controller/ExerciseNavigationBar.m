//
//  ExerciseNavigationBar.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExerciseNavigationBar.h"
#import "CGExtensions.h"
#import "UILabel+HTML.h"



#define CLOSE_BUTTON_IMAGE_NAME         @"Navigation Bar Close Button"

#define TEXT_MARGIN_RIGHT               15

#define TEXT_FORMAT             @"<b>%ld</b>/%ld"   // HTML


@implementation ExerciseNavigationBar

@synthesize delegate;
@synthesize closeButton;
@synthesize progressBar;
@synthesize progressLabel;
@synthesize currentPosition;
@synthesize totalPositions;
@synthesize fontName;
@synthesize fontSize;
@synthesize textColor;
@synthesize barForegroundColor;
@synthesize barBackgroundColor;
@synthesize progressBarHeight;


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
}


- (void) setCurrentPosition:(NSInteger)p_currentPosition {

    currentPosition = p_currentPosition;
    
    [self _updateProgressBar];
    [self _updateProgressLabel];
}




#pragma mark - View, Layout, Constraints

//- (void) didMoveToSuperview {
//    
//    if (self.superview) {
//        
//        [self createView];
//    }
//}


- (void) layoutSubviews {
    
    [super layoutSubviews];
    
}


- (void) updateConstraints {

    [super layoutSubviews];

    
    [self removeConstraints:self.constraints];
    [self.closeButton removeConstraints:self.closeButton.constraints];
    [self.progressBar removeConstraints:self.progressBar.constraints];
    
    
//    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[self(40)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(self)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[closeButton(40)]-0-[progressBar]-15-[progressLabel]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:@{} views:NSDictionaryOfVariableBindings(closeButton, progressBar, progressLabel)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[closeButton(40)]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(closeButton)]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.closeButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self.progressBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[progressBar(height)]" options:0 metrics:@{@"height" : @(self.progressBarHeight)} views:NSDictionaryOfVariableBindings(progressBar)]];

    
    [self invalidateIntrinsicContentSize];
    
    [super updateConstraints];
}


- (void) createView {
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage* buttonImage = [UIImage imageNamed:CLOSE_BUTTON_IMAGE_NAME inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:self.traitCollection];  // no clue what happens here...
    [self.closeButton setImage:buttonImage forState:UIControlStateNormal];
    self.closeButton.contentMode = UIViewContentModeCenter;
    [self.closeButton addTarget:self action:@selector(handleClose:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
    
    
    // progress bar
    self.progressBar = [[ProgressBar alloc] init];
    self.progressBar.backgroundColor = [UIColor clearColor];
    self.progressBar.barBackgroundColor = self.barBackgroundColor;
    self.progressBar.barForegroundColor = self.barForegroundColor;
    [self addSubview:self.progressBar];

    
    // label
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.progressLabel setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:self.progressLabel];

    
    [self _updateProgressBar];
    [self _updateProgressLabel];
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return YES;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


- (void) _updateProgressBar {

    if (self.progressBar) {
    
        NSInteger finishedAdjustment = _progressBarFinished ? 1 : 0;
        NSInteger barPosition = MAX(self.currentPosition - 1 + finishedAdjustment, 0);  // safety, cant be negative (shudnt be)
        
        self.progressBar.percentage = (CGFloat)barPosition / (CGFloat)self.totalPositions;
    }
}


- (void) _updateProgressLabel {
    
    if (self.progressLabel) {
    
        NSString* text = [NSString stringWithFormat:TEXT_FORMAT, self.currentPosition, self.totalPositions];
        UIFont* font = [UIFont fontWithName:self.fontName size:self.fontSize];
        NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:text attributes:@{
                                                                                                          NSFontAttributeName : font,
                                                                                                          NSForegroundColorAttributeName : self.textColor
                                                                                                          }];
        self.progressLabel.attributedText = attributedText;
        
        [self.progressLabel parseHTML];
    }
}



#pragma mark - Actions

- (void) handleClose:(UIButton*) sender {
    
    if ([self.delegate respondsToSelector:@selector(exerciseNavigationBarDidReceiveCloseCommand:)]) {
        
        [self.delegate exerciseNavigationBarDidReceiveCloseCommand:self];
    }
}



#pragma mark - Interface Builder

- (void) prepareForInterfaceBuilder {
    
    [self createView];
}

@end
