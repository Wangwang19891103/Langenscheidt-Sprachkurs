//
//  SCRLabel.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 01.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "SnakeLabel.h"
#import "RoundedRectImage.h"



#define GREEN                   [UIColor colorWithRed:51/255.0 green:172/255.0 blue:63/255.0 alpha:1.0]
#define RED                     [UIColor colorWithRed:213/255.0 green:0/255.0 blue:14/255.0 alpha:1.0]
#define BLUE                    [UIColor colorWithRed:0/255.0 green:151/255.0 blue:189/255.0 alpha:1.0]
#define WHITE                   [UIColor whiteColor]
#define ALMOST_WHITE            [UIColor colorWithWhite:0.97 alpha:1.0]
#define GRAY                    [UIColor colorWithWhite:0.85 alpha:1.0]
#define BLACK                   [UIColor blackColor]



#define LAYOUT_MARGINS          UIEdgeInsetsMake(0,0,0,0)

#define BACKGROUND_COLOR_NORMAL     ALMOST_WHITE
#define BORDER_COLOR_NORMAL         BLUE
#define TEXT_COLOR_NORMAL           BLUE

#define BACKGROUND_COLOR_SELECTED      BLUE
#define BORDER_COLOR_SELECTED          nil
#define TEXT_COLOR_SELECTED            WHITE

#define BACKGROUND_COLOR_CORRECT    GREEN
#define BORDER_COLOR_CORRECT        nil
#define TEXT_COLOR_CORRECT          WHITE

#define BACKGROUND_COLOR_WRONG    RED
#define BORDER_COLOR_WRONG        nil
#define TEXT_COLOR_WRONG          WHITE

#define BACKGROUND_COLOR_PREFIX      GRAY
#define BORDER_COLOR_PREFIX          nil
#define TEXT_COLOR_PREFIX            WHITE


#define FONT                     [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0f]

#define BORDER_WIDTH                2.0f
#define CORNER_RADIUS               5.0f


@implementation SnakeLabel

//@synthesize selected;
@synthesize string;
@synthesize correctAnswer;
@synthesize state;


- (id) initWithString:(NSString*) p_string {
    
    self = [super init];
    
    self.string = p_string;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layoutMargins = LAYOUT_MARGINS;
    
    [self _createImages];
    
    return self;
}


- (void) setState:(SnakeLabelState)p_state {
    
    state = p_state;
    
    [self _updateVisuals];
}



+ (BOOL) requiresConstraintBasedLayout {
    
    return NO;
}


- (CGSize) intrinsicContentSize {
    
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}


- (void) createView {
    
    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_imageView];

    _label = [[UILabel alloc] init];
    _label.translatesAutoresizingMaskIntoConstraints = NO;
    _label.font = FONT;
    _label.text = self.string;
    _label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_label];

    [self _updateVisuals];
}


- (void) updateConstraints {
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_imageView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_imageView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_imageView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_imageView)]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_label]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_label)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_label]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_label)]];
    
    [super updateConstraints];
}


- (void) _createImages {
    
    _imageNormal = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_NORMAL cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_NORMAL];
    _imageSelected = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_SELECTED cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_SELECTED];
    _imageCorrect = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_CORRECT cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_CORRECT];
    _imageWrong = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_WRONG cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_WRONG];
    _imagePrefix = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_PREFIX cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_PREFIX];
}


- (void) _updateVisuals {
    
    switch (self.state) {

        case Normal:
            _imageView.image = _imageNormal;
            _label.textColor = TEXT_COLOR_NORMAL;
            break;

        case Selected:
            _imageView.image = _imageSelected;
            _label.textColor = TEXT_COLOR_SELECTED;
            break;

        case Correct:
            _imageView.image = _imageCorrect;
            _label.textColor = TEXT_COLOR_CORRECT;
            break;

        case Wrong:
            _imageView.image = _imageWrong;
            _label.textColor = TEXT_COLOR_WRONG;
            break;

        case Prefix:
            _imageView.image = _imagePrefix;
            _label.textColor = TEXT_COLOR_PREFIX;
            break;

        default:
            break;
    }
}


- (NSString*) description {
    
    return [NSString stringWithFormat:@"SnakeLabel (string=%@, state=%ld)", self.string, self.state];
}

@end
