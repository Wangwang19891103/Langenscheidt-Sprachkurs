//
//  SCRLabel.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 01.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "SCRLabel.h"
#import "RoundedRectImage.h"


// background colors
#define SCR_GREEN               [UIColor colorWithRed:51/255.0 green:172/255.0 blue:63/255.0 alpha:1.0]
#define SCR_ALMOST_WHITE        [UIColor colorWithWhite:0.97 alpha:1.0]

// fonts
#define SCR_REGULAR             [UIFont fontWithName:@"HelveticaNeue" size:14.0f]
#define SCR_BOLD                [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]





#define LAYOUT_MARGINS          UIEdgeInsetsMake(13,13,13,13)

#define BACKGROUND_COLOR_NORMAL     SCR_ALMOST_WHITE
#define BORDER_COLOR_NORMAL         [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]
#define TEXT_COLOR_NORMAL           [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]

#define BACKGROUND_COLOR_GHOST      [UIColor colorWithWhite:0.85 alpha:1.0]
#define BORDER_COLOR_GHOST          nil
#define TEXT_COLOR_GHOST            [UIColor whiteColor]

#define BACKGROUND_COLOR_DRAGGED    [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]
#define BORDER_COLOR_DRAGGED        nil
#define TEXT_COLOR_DRAGGED          [UIColor whiteColor]

#define BACKGROUND_COLOR_IMMOVABLE    [UIColor colorWithRed:48/255.0 green:155/255.0 blue:189/255.0 alpha:1.0]
#define BORDER_COLOR_IMMOVABLE        nil
#define TEXT_COLOR_IMMOVABLE          [UIColor whiteColor]

#define BACKGROUND_COLOR_CORRECT    SCR_GREEN
#define BORDER_COLOR_CORRECT        nil
#define TEXT_COLOR_CORRECT          [UIColor whiteColor]

#define BACKGROUND_COLOR_WRONG    [UIColor colorWithRed:210/255.0 green:17/255.0 blue:17/255.0 alpha:1.0]
#define BORDER_COLOR_WRONG        nil
#define TEXT_COLOR_WRONG          [UIColor whiteColor]

//#define FONT                     [UIFont fontWithName:@"HelveticaNeue" size:14.0f]

#define BORDER_WIDTH                2.0f
#define CORNER_RADIUS               5.0f


@implementation SCRLabel

@synthesize state;
@synthesize string;


- (id) initWithString:(NSString*) p_string {
    
    self = [super init];
    
    self.string = p_string;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layoutMargins = LAYOUT_MARGINS;
    state = Normal;
    
    [self _createImages];
    
    return self;
}


- (void) setState:(SCRLabelState)p_state {

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
//    _label.font = FONT;
    _label.text = self.string;
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
    _imageGhost = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_GHOST cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_GHOST];
    _imageDragged = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_DRAGGED cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_DRAGGED];
    _imageImmovable = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_IMMOVABLE cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_IMMOVABLE];
    _imageCorrect = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_CORRECT cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_CORRECT];
    _imageWrong = [RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR_WRONG cornerRadius:CORNER_RADIUS borderWidth:BORDER_WIDTH borderColor:BORDER_COLOR_WRONG];
}


- (void) _updateVisuals {
    
    switch (self.state) {

        case Normal:
            _imageView.image = _imageNormal;
            _label.textColor = TEXT_COLOR_NORMAL;
            _label.font = SCR_BOLD;
            break;

        case Ghost:
            _imageView.image = _imageGhost;
            _label.textColor = TEXT_COLOR_GHOST;
            _label.font = SCR_BOLD;
            break;

        case Dragged:
            _imageView.image = _imageDragged;
            _label.textColor = TEXT_COLOR_DRAGGED;
            _label.font = SCR_BOLD;
            break;

        case Immovable:
            _imageView.image = _imageImmovable;
            _label.textColor = TEXT_COLOR_IMMOVABLE;
            _label.font = SCR_BOLD;
            break;

        case Correct:
            _imageView.image = _imageCorrect;
            _label.textColor = TEXT_COLOR_CORRECT;
            _label.font = SCR_REGULAR;
            break;

        case Wrong:
            _imageView.image = _imageWrong;
            _label.textColor = TEXT_COLOR_WRONG;
            _label.font = SCR_REGULAR;
            break;

        default:
            break;
    }
}


- (void) setNormalAppearance {
    
    self.state = Normal;
    [self _updateVisuals];
}


- (void) setGhostAppearance {
    
    self.state = Ghost;
    [self _updateVisuals];
}


//- (UIView*) aaa {
//    
//    UIView* aa = [[UIView alloc] initWithFrame:self.frame];
//    aa.backgroundColor = [UIColor redColor];
//    aa.userInteractionEnabled = NO;
//    
//    return aa;
//}


- (NSString*) description {
    
    return [NSString stringWithFormat:@"SCRLabel (string=%@, state=%ld)", self.string, self.state];
}

@end
