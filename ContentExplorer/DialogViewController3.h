//
//  DialogViewController2.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 26.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Pearl.h"
#import "StackView.h"
#import "AudioPlayer.h"
//#import "Dialog.h"
#import "ExerciseTextView2.h"
#import "DialogFeeder.h"


@interface DialogViewController3 : UIViewController <UITextFieldDelegate, DialogFeederDelegate> {
    
    NSArray* _dialogs;
    CGFloat _posY;
    
    UIView* _lastView;

    DialogFeeder* _feeder;
    
    BOOL _viewFinishedLoading;
    
    UIView* _bottomMostItem;
    BOOL _needsScrollToVisible;
    
    ExerciseTextView2* _currentTextView;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet StackView *contentStackView;
@property (strong, nonatomic) IBOutlet ExerciseTextView2 *prototypeTextView;
@property (strong, nonatomic) IBOutlet StackView *prototypeTextContainerView;
@property (strong, nonatomic) IBOutlet UITextView *prototypeLanguage2TextView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomDummyHeightConstraint;

@property (nonatomic, assign) Pearl* pearl;

@end
