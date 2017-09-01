//
//  CustomKeyboardInputViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 25.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "CustomKeyboardInputViewController.h"
#import "NSArray+Extensions.h"
#import "RoundedRectButton.h"
#import "UIView+RemoveConstraints.h"


// NOTE: removing height constraint of self.view in constraint pass and layout pass


#define FONT        [UIFont fontWithName:@"HelveticaNeue" size:18.0]
#define TEXT_COLOR_NORMAL   [UIColor colorWithRed:60/255.0 green:160/255.0 blue:200/255.0 alpha:1.0]
#define TEXT_COLOR_SPECIAL      [UIColor whiteColor]
#define BORDER_COLOR    [UIColor colorWithRed:60/255.0 green:160/255.0 blue:200/255.0 alpha:1.0]
#define BACKGROUND_COLOR_NORMAL     [UIColor whiteColor]
#define BACKGROUND_COLOR_SPECIAL    [UIColor colorWithRed:60/255.0 green:160/255.0 blue:200/255.0 alpha:1.0]
#define CORNER_RADIUS       5.0f
#define BORDER_WIDTH        2.0f

#define BUTTON_SIZE     CGSizeMake(34,37)
#define BACKSPACE_BUTTON_SIZE     CGSizeMake(50,37)
#define ENTER_BUTTON_SIZE     CGSizeMake(80,37)

#define HORIZONTAL_SPACING      3.0f
#define VERTICAL_SPACING        3.0f
#define LAYOUT_MARGINS          UIEdgeInsetsMake(15,15,15,15)


@implementation CustomKeyboardInputViewController

@synthesize layoutView;
@synthesize string;
@synthesize responder;


- (id) init {
    
    self = [super init];
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self createView];
}



- (void) createView {
    
    NSLog(@"createView");
    
    self.layoutView = [[LineLayoutView3 alloc] init];
    self.layoutView.delegate = self;
    self.layoutView.horizontalSpacing = HORIZONTAL_SPACING;
    self.layoutView.verticalSpacing = VERTICAL_SPACING;
    self.layoutView.layoutMargins = LAYOUT_MARGINS;
    
    [self.view addSubview:self.layoutView];
    
    [self _createLetters];
    
    [self _createButtons];
}


- (void) viewWillLayoutSubviews {

    NSLog(@"willlayout");
    
    [super viewWillLayoutSubviews];
    
    
    // removing the height constraint seems necessary both in updateViewConstraints (once the view is created) and everytime the layout pass is being run
    
    [self _removeHeightConstraint];
}

- (void) viewDidLayoutSubviews {
    
    NSLog(@"didlayout");
    
    [super viewDidLayoutSubviews];
    
//    CGFloat layoutViewHeight = self.layoutView.frame.size.height;
//    
//    self.inputView.frame = ({
//        
//        CGRect newRect = self.inputView.frame;
//        newRect.size.height = layoutViewHeight;
//        
//        newRect;
//    });
}

- (void) updateViewConstraints {  // called only once
    
    NSLog(@"update cons");
    
//    [self _removeHeightConstraint];

//    [self.inputView removeConstraintsAffectingSubview:self.layoutView];
    
    UIView* theView = self.inputView;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[layoutView(theView)]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(layoutView, theView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[layoutView]-0@999-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(layoutView)]];

//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[layoutView]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(layoutView)]];

    // bottom constraint at lower priority than 1000 (as the 216 constraint) so it doesnt produce an error. the 216 constraint is removed anyway before the layout finishes
    
    
    [super updateViewConstraints];
}


- (void) _removeHeightConstraint {
    
    NSArray* constraints = [self.inputView constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical];
    
    for (NSLayoutConstraint* constraint in constraints) {
        
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            
            if (constraint.firstItem == self.inputView) {
                
                NSLog(@"removing con: %@", constraint);
                constraint.active = NO;
            }
        }
    }
}


- (void) _createLetters {
    
    _letters = [NSMutableArray array];
    
    NSArray* words = [self.string componentsSeparatedByString:@" "];
    uint index = 0;
    
    for (NSString* word in words) {
        
        NSMutableArray* subItems = [NSMutableArray array];
        
        for (uint i = 0; i < word.length; ++i) {
            
            NSString* charString = [[word substringWithRange:NSMakeRange(i, 1)] lowercaseString];
            
            [subItems addObject:charString];
        }
        
        NSArray* subItems2 = [NSArray randomizedArrayFromArray:subItems];
        
        [_letters addObjectsFromArray:subItems2];
        
        
        if (index != words.count -1) {
            
            [_letters addObject:@" "];
        }
        
        ++index;
    }
}


- (void) _createButtons {
    
    NSDictionary* attributes = @{
                                 NSFontAttributeName : FONT,
                                 NSForegroundColorAttributeName : TEXT_COLOR_NORMAL
                                 };

    // backspace and enter buttons

    UIImage* backspaceImage = [UIImage imageNamed:@"Custom_Keyboard_Backspace"];
    
    _backspaceButton = [[RoundedRectButton alloc] init];
//    [_backspaceButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"back" attributes:@{NSFontAttributeName : FONT, NSForegroundColorAttributeName : TEXT_COLOR_SPECIAL}] forState:UIControlStateNormal];
    [_backspaceButton setImage:backspaceImage forState:UIControlStateNormal];
    _backspaceButton.contentMode = UIViewContentModeCenter;
    [_backspaceButton addTarget:self action:@selector(actionBackspace) forControlEvents:UIControlEventTouchUpInside];
    _backspaceButton.tintColor = BACKGROUND_COLOR_SPECIAL;
    _backspaceButton.cornerRadius = CORNER_RADIUS;
    _backspaceButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.layoutView addCustomLayoutedSubview:_backspaceButton];
    [self.layoutView addSubview:_backspaceButton];
    [_backspaceButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_backspaceButton(width)]" options:0 metrics:@{@"width" : @(BACKSPACE_BUTTON_SIZE.width)} views:NSDictionaryOfVariableBindings(_backspaceButton)]];
    [_backspaceButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_backspaceButton(height)]" options:0 metrics:@{@"height" : @(BACKSPACE_BUTTON_SIZE.height)} views:NSDictionaryOfVariableBindings(_backspaceButton)]];

    _enterButton = [[RoundedRectButton alloc] init];
    [_enterButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Fertig" attributes:@{NSFontAttributeName : FONT, NSForegroundColorAttributeName : TEXT_COLOR_SPECIAL}] forState:UIControlStateNormal];
    [_enterButton addTarget:self action:@selector(actionEnter) forControlEvents:UIControlEventTouchUpInside];
    _enterButton.tintColor = BACKGROUND_COLOR_SPECIAL;
    _enterButton.cornerRadius = CORNER_RADIUS;
    _enterButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.layoutView addCustomLayoutedSubview:_enterButton];
    [self.layoutView addSubview:_enterButton];
    [_enterButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_enterButton(width)]" options:0 metrics:@{@"width" : @(ENTER_BUTTON_SIZE.width)} views:NSDictionaryOfVariableBindings(_enterButton)]];
    [_enterButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_enterButton(height)]" options:0 metrics:@{@"height" : @(ENTER_BUTTON_SIZE.height)} views:NSDictionaryOfVariableBindings(_enterButton)]];

    
    // letter buttons
    
    uint tag = 0;
    
    for (NSString* letter in _letters) {
        
        RoundedRectButton* button = [[RoundedRectButton alloc] init];
        NSAttributedString* attributedString = [[NSAttributedString alloc] initWithString:letter attributes:attributes];
        [button setAttributedTitle:attributedString  forState:UIControlStateNormal];
        [button addTarget:self action:@selector(actionType:) forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = BACKGROUND_COLOR_NORMAL;
        button.borderColor = BORDER_COLOR;
        button.cornerRadius = CORNER_RADIUS;
        button.borderWidth = BORDER_WIDTH;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        button.tag = tag;
        
        [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(width)]" options:0 metrics:@{@"width" : @(BUTTON_SIZE.width)} views:NSDictionaryOfVariableBindings(button)]];
        [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(height)]" options:0 metrics:@{@"height" : @(BUTTON_SIZE.height)} views:NSDictionaryOfVariableBindings(button)]];
        
        [self.layoutView addSubview:button];
        
        ++tag;
    }
}



- (IBAction) actionType:(UIButton*)sender {
    
    [self _playClick];
    
    NSInteger index = sender.tag;
    NSString* charString = _letters[index];
    [self.textDocumentProxy insertText:charString];
}


- (IBAction) actionBackspace {
    
    [self _playClick];

    [self.textDocumentProxy deleteBackward];
}


- (IBAction) actionEnter {
    
    [self _playClick];

//    [self.responder resignFirstResponder];
    
    [self.textDocumentProxy insertText:@"\n"];
}


- (void) _playClick {
    
    [[UIDevice currentDevice] playInputClick];
}



#pragma mark - Delegate

- (BOOL) respectSubviewForLineLayout:(UIView *)subview {
    
    return YES;
}


- (NSArray*) lineLayoutView:(LineLayoutView3 *)layoutView customLayoutConstraintsForSubview:(UIView *)subview {
    
    if (subview == _backspaceButton) {
        
        NSMutableArray* constraints = [NSMutableArray array];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subview]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[subview]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview)]];
        
        return constraints;
    }
    else if (subview == _enterButton) {
        
        NSMutableArray* constraints = [NSMutableArray array];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[subview]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(subview)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_backspaceButton]-(spacing)-[subview]-(>=bottom)-|" options:0 metrics:@{@"spacing" : @(layoutView.verticalSpacing), @"bottom" : @(layoutView.layoutMargins.bottom)} views:NSDictionaryOfVariableBindings(_backspaceButton, subview)]];
        
        return constraints;
    }

    else return nil;
}



#pragma mark - UIInputViewAudioFeedback protocol

- (BOOL) enableInputClicksWhenVisible {
    
    return YES;
}



@end
