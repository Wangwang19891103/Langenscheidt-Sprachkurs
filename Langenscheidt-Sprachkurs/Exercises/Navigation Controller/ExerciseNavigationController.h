//
//  ExerciseNavigationController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExerciseNavigationBar.h"
#import "RoundedRectButton.h"
#import "Pearl.h"
#import "Exercise.h"
//#import "StackView.h"
#import "ExercisePopupViewController.h"
#import "DialogAudioPlayer.h"
#import "FadeView.h"
#import "ExerciseIntroViewController.h"
#import "ExerciseScoreViewController.h"

#import "ModalStackViewController.h"


#define ExerciseNavigationController_loaded


//typedef NS_ENUM(NSInteger, ExerciseNavigationControllerBottomButtonMode) {
//    
//    Check,
//    Next
//};


@class ExerciseViewController;




@interface ExerciseNavigationController : UIViewController <ExerciseNavigationBarDelegate> {
    
    NSMutableArray* _exerciseViewControllers;
    
    ExerciseViewController* _currentExerciseViewController;
    
    ExercisePopupViewController* _popupViewController;
    
//    DialogAudioPlayer* _player;
    
    NS_ENUM(NSInteger, _bottomButtonMode) {
        
        Check,
        Next
    };
    
    ExerciseIntroViewController* _introViewController;
    
    ExerciseScoreViewController* _scoreViewController;
    
    Pearl* _nextPearl;
    
    NSInteger _numberOfInvisibleExerciseClusters;
    
    UIButton* _popupButton;
    
    BOOL _presentingCourseCompletionScreen;
    
    BOOL _presentingShop;
    
    // DEV
    
    BOOL _DEVskipToScoreScreen;
    

}


@property (strong, nonatomic) IBOutlet ExerciseNavigationBar *navigationBar;

@property (strong, nonatomic) IBOutlet UIView *navigationBarContainer;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet RoundedRectButton *bottomButton;

//@property (nonatomic, strong) Pearl* pearl;

@property (nonatomic, strong) ExerciseCluster* exerciseCluster;

@property (nonatomic, strong) Exercise* exercise;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonAreaHeightConstraint;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;
@property (strong, nonatomic) IBOutlet FadeView *fadeView;

@property (strong, nonatomic) IBOutlet UIView *exerciseContainerView;
@property (strong, nonatomic) IBOutlet UIView *fullscreenContainerView;

@property (strong, nonatomic) IBOutlet UIView* fullscreenNoScrollContainerView;

@property (strong, nonatomic) IBOutlet UIView *titleContainerView;

@property (nonatomic, readonly) NSInteger currentExerciseIndex;

@property (nonatomic, readonly) ExerciseViewController* currentExerciseViewController;  // needed for starting exercise from block

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@property (nonatomic, assign) uint index;

@property (strong, nonatomic) IBOutlet UIButton *audioButton;
@property (strong, nonatomic) IBOutlet UIView *explanationContainer;
@property (strong, nonatomic) IBOutlet UILabel *explanationLabel;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint* keyboardHeightConstraint;

@property (nonatomic, strong) IBOutlet UIView* contentWrapperView;

@property (strong, nonatomic) IBOutlet UIView *scrollSeparatorTop;

@property (strong, nonatomic) IBOutlet UIView *scrollSeparatorBottom;

@property (nonatomic, readonly) BOOL presentingPopup;


- (IBAction) actionBottomButton;

- (IBAction) actionAudioButton;


- (void) setBottomButtonHidden:(BOOL) hidden animated:(BOOL) animated;

- (void) openInNavigationController:(UINavigationController*) navigationController withIntroScreen:(BOOL) withIntroScreen;

- (void) handlePopupButtonForFile:(NSString*) popupFile;

@end
