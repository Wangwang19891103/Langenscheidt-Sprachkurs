//
//  SnakeLabel.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "SnakeLabel.h"


#define FONT        [UIFont fontWithName:@"HelveticaNeue" size:18.0]
#define TEXT_COLOR_NORMAL   [UIColor colorWithRed:60/255.0 green:160/255.0 blue:200/255.0 alpha:1.0]
#define TEXT_COLOR_SELECTED [UIColor whiteColor]
#define BORDER_COLOR    [UIColor colorWithRed:60/255.0 green:160/255.0 blue:200/255.0 alpha:1.0]
#define BACKGROUND_COLOR_SELECTED   [UIColor colorWithRed:60/255.0 green:160/255.0 blue:200/255.0 alpha:1.0]
#define BACKGROUND_COLOR_NORMAL     [UIColor whiteColor]


@implementation SnakeLabel

@synthesize selected;
@synthesize string;


- (id) init {
    
    self = [super init];
    
    self.layer.borderWidth = 2.0;
    self.layer.cornerRadius = 3.0;
    self.textAlignment = NSTextAlignmentCenter;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layer.borderColor = BORDER_COLOR.CGColor;
    
    return self;
}

- (void) didMoveToSuperview {
    
    if (self.superview) {
        
        [self _updateView];
    }
}


- (void) setSelected:(BOOL)p_selected {
    
    selected = p_selected;
    
    [self _updateView];
}


- (void) setString:(NSString *)p_string {
    
    string = p_string;

    [self _createAttributedStrings];
    
    [self _updateView];
}


- (void) _createAttributedStrings {
    
    _normalString = [[NSAttributedString alloc] initWithString:self.string attributes:@{
                                                                                        NSFontAttributeName : FONT,
                                                                                        NSForegroundColorAttributeName : TEXT_COLOR_NORMAL
                                                                                        }];
    
    _selectedString = [[NSAttributedString alloc] initWithString:self.string attributes:@{
                                                                                          NSFontAttributeName : FONT,
                                                                                          NSForegroundColorAttributeName : TEXT_COLOR_SELECTED
                                                                                          }];
}


- (void) _updateView {
    
    if (selected) {
        
        self.attributedText = _selectedString;
        self.backgroundColor = BACKGROUND_COLOR_SELECTED;
    }
    else {
        
        self.attributedText = _normalString;
        self.backgroundColor = BACKGROUND_COLOR_NORMAL;
    }
}


@end
