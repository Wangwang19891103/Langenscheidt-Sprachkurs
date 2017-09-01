//
//  MCHButton.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "MCHButton.h"
#import "RoundedRectImage.h"


#define GREEN                   [UIColor colorWithRed:51/255.0 green:172/255.0 blue:63/255.0 alpha:1.0]
#define RED                     [UIColor colorWithRed:213/255.0 green:0/255.0 blue:14/255.0 alpha:1.0]
#define BLUE                    [UIColor colorWithRed:0/255.0 green:151/255.0 blue:189/255.0 alpha:1.0]
#define WHITE                   [UIColor whiteColor]
#define ALMOST_WHITE            [UIColor colorWithWhite:0.97 alpha:1.0]

#define BACKGROUND_COLOR_NORMAL     ALMOST_WHITE
#define BORDER_COLOR_NORMAL         BLUE
#define TEXT_COLOR_NORMAL           BLUE

#define BACKGROUND_COLOR_SELECTED     BLUE
#define BORDER_COLOR_SELECTED         nil
#define TEXT_COLOR_SELECTED           WHITE

#define BACKGROUND_COLOR_CORRECT     GREEN
#define BORDER_COLOR_CORRECT         nil
#define TEXT_COLOR_CORRECT           WHITE

#define BACKGROUND_COLOR_WRONG      RED
#define BORDER_COLOR_WRONG         nil
#define TEXT_COLOR_WRONG           WHITE


#define CORNER_RADIUS           5.0
#define BORDER_WIDTH            2.0

#define BACKGROUND_IMAGE_INSETS       UIEdgeInsetsMake(5, 5, 5, 5)

#define TEXT_INSETS        UIEdgeInsetsMake(17, 20, 17, 20)

#define FONT_NAME                           @"HelveticaNeue-Bold"
#define FONT_SIZE                           14.0


@implementation MCHButton

@synthesize buttonState;
@synthesize string;


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
    buttonState = Normal;
    
    [self _createImages];
    
//    self.backgroundColor = [UIColor redColor];
}


- (void) _createImages {
    
    _imageNormal = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_NORMAL cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_NORMAL];
    _imageSelected = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_SELECTED cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_SELECTED];
    _imageCorrect = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_CORRECT cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_CORRECT];
    _imageWrong = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_WRONG cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_WRONG];
    
    _wrongImage = [UIImage imageNamed:@"Cross_MCH"];
    _correctImage = [UIImage imageNamed:@"Check_MCH"];
}


#pragma mark - Setters 

- (void) setButtonState:(MCHButtonState)p_buttonState {
    
    buttonState = p_buttonState;
    
    [self _updateView];
}


#pragma mark - View

- (void) didMoveToSuperview {
    
    if (self.superview) {
        
        [self _updateView];
    }
}

#pragma mark - View, Layout, Constraints

- (void) createView {
    
    // imageView
    
    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_imageView];


    // label
    
    _label = [[UILabel alloc] init];
    _label.numberOfLines = 0;
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:_label];

    
    // check image view
    
    _checkImageView = [[UIImageView alloc] init],
    _checkImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:_checkImageView];
    
}


- (void) layoutSubviews {
    
    [super layoutSubviews];
}


- (void) updateConstraints {
    
    // ..
    
    [self _arrangeSubviews];
    
    [self invalidateIntrinsicContentSize];
    
    [super updateConstraints];
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


+ (BOOL) requiresConstraintBasedLayout {
    
    return NO;
}



#pragma mark - View Logic

- (void) _arrangeSubviews {
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_imageView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_imageView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_imageView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_imageView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[_label]-(bottom)-|" options:0 metrics:@{@"top" : @(TEXT_INSETS.top), @"bottom" : @(TEXT_INSETS.bottom)} views:NSDictionaryOfVariableBindings(_label)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[_label]-(right)-|" options:0 metrics:@{@"left" : @(TEXT_INSETS.left), @"right" : @(TEXT_INSETS.right)} views:NSDictionaryOfVariableBindings(_label)]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_checkImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self  attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_checkImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self  attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
}


#pragma mark - State Logic

- (void) _updateView {
    
    UIImage* image = nil;
    UIColor* textColor = nil;
    UIImage* checkImage = nil;
    
    
    switch (self.buttonState) {

        case Normal:
            image = _imageNormal;
            textColor = TEXT_COLOR_NORMAL;
            break;

        case Selected:
            image = _imageSelected;
            textColor = TEXT_COLOR_SELECTED;
            break;

        case Correct:
            image = _imageCorrect;
            textColor = TEXT_COLOR_CORRECT;
            checkImage = _correctImage;
            break;

        case Missed:
            image = _imageCorrect;
            textColor = TEXT_COLOR_CORRECT;
            break;

        case Wrong:
            image = _imageWrong;
            textColor = TEXT_COLOR_WRONG;
            checkImage = _wrongImage;
            break;

        default:
            image = _imageNormal;
            textColor = TEXT_COLOR_NORMAL;
            break;
    }
    
    assert(image);
    assert(textColor);
    
    UIImage* backgroundImage = [image resizableImageWithCapInsets:BACKGROUND_IMAGE_INSETS resizingMode:UIImageResizingModeStretch];
    
    UIFont* font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE];
    
    NSDictionary* attributes = @{
                                 NSFontAttributeName : font,
                                 NSForegroundColorAttributeName : textColor
                                 };
    
    NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:self.string attributes:attributes];
    
    
    _imageView.image = backgroundImage;
    _label.attributedText = attributedString;
    _checkImageView.image = checkImage;
}

@end
