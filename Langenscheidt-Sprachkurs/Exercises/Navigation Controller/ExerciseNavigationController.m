//
//  ExerciseNavigationController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExerciseNavigationController.h"
#import "ContentDataManager.h"
#import "ExerciseDictionary.h"
#import "ExerciseViewController.h"
#import "UILabel+HTML.h"
#import "UserProgressManager.h"
#import "NavigationController.h"
#import "Exercise_VocabFlow_ViewController.h"
#import "CourseCompletionViewController.h"
#import "SettingsManager.h"

#import "CourseViewController.h"
#import "LessonViewController.h"
#import "PearlViewController.h"

#import "SubscriptionManager.h"

#import "ShopPopupViewController.h"


#import "ScreenName.h"
#import "LTracker.h"



#define BOTTOM_BUTTON_TITLE_CHECK           @"PRÜFEN"
#define BOTTOM_BUTTON_TITLE_NEXT            @"WEITER"

#define BOTTOM_BUTTON_AREA_HEIGHT           60.0f

#define BOTTOM_BUTTON_ANIMATION_DURATION    0.2f

#define TITLE_LABEL_INSETS_NORMAL           UIEdgeInsetsMake(6,20,13,20)
#define TITLE_LABEL_INSETS_POPUP            UIEdgeInsetsMake(6,60,13,60)

#define EXPLANATION_CONTAINER_INSETS        UIEdgeInsetsMake(0,8,5,8)

#define TITLE_FONT      [UIFont fontWithName:@"HelveticaNeue" size:14.0]
#define TITLE_TEXTCOLOR     [UIColor colorWithWhite:0.33 alpha:1.0]

#define CONTENT_TOP_MARGIN           0  // was 20
#define CONTENT_BOTTOM_MARGIN           30


@implementation ExerciseNavigationController

@synthesize navigationBar;
@synthesize navigationBarContainer;
@synthesize titleLabel;
@synthesize bottomButton;
//@synthesize pearl;
@synthesize exercise;
@synthesize bottomButtonAreaHeightConstraint;
@synthesize exerciseContainerView;
@synthesize titleContainerView;
@synthesize widthConstraint;
@synthesize scrollview;
@synthesize index;
@synthesize audioButton;
@synthesize explanationContainer;


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
    
    
}


- (void) initialize {

    _exerciseViewControllers = [NSMutableArray array];
    
//    self.hidesBottomBarWhenPushed = YES;
    
    
    // DEV
    
    _DEVskipToScoreScreen = [[[SettingsManager instanceNamed:@"dev"] valueForKey:@"skipToScoreScreen"] boolValue];
}



#pragma mark - View

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    {
        Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:self.exerciseCluster];
        GATrackingSetScreenName(@"Übungen");
        GATrackingSetTrackScreenViews(YES);
        LTrackerSetContentPath([ScreenName nameForPearl:pearl]);
    }
    
    
//    self.scrollview.alwaysBounceVertical = NO;
    
    
    [self _registerKeyboardNotifications];

    
    [self _createExerciseViewControllers];

    
    self.fadeView.enabled = NO;
    
    
    
    [self _setNumberOfInvisibleExerciseClusters];
    
    
    // navigation bar

    self.navigationBar.totalPositions = _exerciseViewControllers.count + _numberOfInvisibleExerciseClusters;
    [self _updateNavigationBar];
    
    [self.navigationBar createView];
    
    self.navigationBar.delegate = self;

    [self.navigationBarContainer addSubview: self.navigationBar];
    
    [self.navigationBarContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[navigationBar]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(navigationBar)]];
    [self.navigationBarContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[navigationBar]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(navigationBar)]];
    
    
    
    // bottom button
    
//    [self _setBottomButtonHidden:YES animated:NO];
    
    
    // exercises
    
    [self _showExerciseWithIndex:0 animated:NO];

    
    // content tap
    
    [self _addContentTapRecognizer];

    
    
    // update user lesson
    
    Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:self.exerciseCluster];

    [self _updateUserLessonWithLesson:pearl.lesson];
    
    
    
    
//    if (_DEVskipToScoreScreen) {
//    
//        [self _DEVSkipToScoreScreen];
//    }
}


- (void) _setNumberOfInvisibleExerciseClusters {

    _numberOfInvisibleExerciseClusters = [[UserProgressManager instance] numberOfExercisesBeforeExerciseCluster:self.exerciseCluster];
}


- (void) _updateNavigationBar {

    self.navigationBar.currentPosition = _currentExerciseIndex + 1 + _numberOfInvisibleExerciseClusters;
    
    // aktueller index (0) + 1 + invisible exercises (thru starting in the middle of the pearl)
    
}


- (void) _populateTitleContainer {
    
    [self.titleContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.font = TITLE_FONT;
    self.titleLabel.textColor = TITLE_TEXTCOLOR;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleContainerView addSubview:self.titleLabel];
    [self.titleLabel setContentHuggingPriority:1000 forAxis:UILayoutConstraintAxisVertical];
    
    UIEdgeInsets insets;
    
    ExerciseViewController* controller = _exerciseViewControllers[self.currentExerciseIndex];
    NSString* popupFile = [self _popupFileForController:controller];
    
    if (popupFile) {
        
        insets = TITLE_LABEL_INSETS_POPUP;
    }
    else {
        
        insets = TITLE_LABEL_INSETS_NORMAL;
    }
    
    
    [self.titleContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[titleLabel]-(right)-|" options:0 metrics:@{@"left" : @(insets.left), @"right" : @(insets.right)} views:NSDictionaryOfVariableBindings(titleLabel)]];
    [self.titleContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[titleLabel]-(==bottom@999,>=bottom@750)-|" options:0 metrics:@{@"top" : @(insets.top), @"bottom" : @(insets.bottom)} views:NSDictionaryOfVariableBindings(titleLabel)]];
    
    
//    if (popupFile) {
//        
//        UIButton* popupButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        popupButton.translatesAutoresizingMaskIntoConstraints = NO;
//        UIImage* popupImage = [UIImage imageNamed:@"Popup"];
//        [popupButton setImage:popupImage forState:UIControlStateNormal];
//        [popupButton addTarget:self action:@selector(actionPopupButton) forControlEvents:UIControlEventTouchUpInside];
//        popupButton.contentMode = UIViewContentModeCenter;
//        [self.titleContainerView addSubview:popupButton];
//        
//        [self.titleContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[popupButton(40)]-(10)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(popupButton)]];
//        [self.titleContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[popupButton]-(>=0)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(popupButton)]];
//    }
    
    
    NSString* explanation = [self _explanationForController:controller];
    
    
    if (explanation) {
        
        self.explanationLabel.text = explanation;
        [self.explanationLabel parseHTML];
        
        self.explanationContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.titleContainerView addSubview:self.explanationContainer];
        
        
        UIEdgeInsets explanationInsets = EXPLANATION_CONTAINER_INSETS;
        
        [self.titleContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[explanationContainer]-(right)-|" options:0 metrics:@{@"left" : @(explanationInsets.left), @"right" : @(explanationInsets.right)} views:NSDictionaryOfVariableBindings(explanationContainer)]];
        [self.titleContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleLabel]-(top)-[explanationContainer]-(>=bottom)-|" options:0 metrics:@{@"top" : @(insets.bottom), @"bottom" : @(explanationInsets.bottom)} views:NSDictionaryOfVariableBindings(explanationContainer, titleLabel)]];
        
    }
    
    
    
    // fade view
    
    if (explanation) {
        
        self.fadeView.topLimitView = self.explanationContainer;
    }
    else {
    
        self.fadeView.topLimitView = self.titleLabel;
    }
    
}


- (void) _handlePopupButtonForController:(ExerciseViewController*) controller {

    NSString* popupFile = [self _popupFileForController:controller];
    
    [self handlePopupButtonForFile:popupFile];
}


- (void) handlePopupButtonForFile:(NSString*) popupFile {

    if (popupFile) {
        
        _popupButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _popupButton.translatesAutoresizingMaskIntoConstraints = NO;
        UIImage* popupImage = [UIImage imageNamed:@"Popup"];
        [_popupButton setImage:popupImage forState:UIControlStateNormal];
        [_popupButton addTarget:self action:@selector(actionPopupButton) forControlEvents:UIControlEventTouchUpInside];
        _popupButton.contentMode = UIViewContentModeCenter;
        [self.view addSubview:_popupButton];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_popupButton(40)]-(15)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_popupButton)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(30)-[_popupButton(40)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_popupButton)]];
    }
    else {
        
        if (_popupButton) {
            
            [_popupButton removeFromSuperview];
        }
    }

}



- (NSString*) _popupFileForController:(ExerciseViewController*) controller {
    
    ExerciseType type = [controller.exerciseDict[@"type"] integerValue];

    if (type == DIALOG) {
        
        return [self _findPopupFileInDialogLines:controller.exerciseDict[@"dialogLines"]];
    }
    else if (type == VOCABFLOW) {
        
        Exercise_VocabFlow_ViewController* controller2 = (Exercise_VocabFlow_ViewController*)controller;
        
        return [controller2 popupFile];
    }
    else {
        
        return controller.exerciseDict[@"popupFile"];
    }
}


- (NSString*) _explanationForController:(ExerciseViewController*) controller {
    
    ExerciseType type = [controller.exerciseDict[@"type"] integerValue];
    
    if (type == VOCABFLOW) {
        
        NSString* explanation = controller.exerciseDict[@"explanation"];
        NSString* topText = controller.exerciseDict[@"topText"];

        if (explanation) return explanation;
        else return topText;

    }
    else {
        
        return controller.exerciseDict[@"explanation"];

    }
}





- (NSString*) _findPopupFileInDialogLines:(NSArray*) array {
    
    for (NSDictionary* line in array) {
        
        if (line[@"popupFile"]) {
            
            return line[@"popupFile"];
        }
    }
    
    return nil;
}


- (void) _addContentTapRecognizer {
    
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleContentTap:)];
    
    [self.view addGestureRecognizer:recognizer];
}


- (void) _handleContentTap:(UIGestureRecognizer*) recognizer {
    
    NSLog(@"content tap");
    
    BOOL exerciseHandlesContentTap = [_currentExerciseViewController shouldHandleContentTap];
    
    if (exerciseHandlesContentTap) {
        
        [_currentExerciseViewController handleContentTap];
    }
    else {
    
        [self.view endEditing:YES];
    }
}

//- (void) updateViewConstraints {
//    
//    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.exerciseContainerView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
//    
//    [self.view addConstraint:self.widthConstraint];
//    
//    [super updateViewConstraints];
//}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    NSLog(@"constraints: %@", self.view.constraints);

}


//- (void) viewWillDisappear:(BOOL)animated {
//    
//    [super viewWillDisappear:animated];
//    
////    [self.navigationController setNavigationBarHidden:NO animated:YES];
//}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}


- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    
}




#pragma mark - Creating Exercise View Controllers

- (void) _createExerciseViewControllers {
    
//    Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:self.exerciseCluster];
    
//    if (pearl.exerciseClusters.count > 0 || self.exercise) {
    
        [self _createExerciseViewControllersFromExerciseClusters];
//    }
}


- (void) _createExerciseViewControllersFromExerciseClusters {

    //TODO: put into and handle as clusters for assigning points
    
    if (self.exerciseCluster) {
    
//        NSArray* exercises = [[ContentDataManager instance] exercisesForPearl:self.pearl];
        Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:self.exerciseCluster];
        NSArray* exercises = [[ContentDataManager instance] exercisesForPearl:pearl beginningAtExerciseCluster:self.exerciseCluster];
        
        for (Exercise* anExercise in exercises) {
            
//            NSLog(@"exercise id: %d, cluster id: %d, pearl id: %d", anExercise.id, anExercise.cluster.id, pearl.id);
            
            ExerciseViewController* controller = [self _createExerciseViewControllerWithExercise:anExercise];
            
            [_exerciseViewControllers addObject:controller];
        }
        
//        if (self.pearl.vocabularies.count > 0) {  // is vocabulary pearl -> needs auto generated exercises
//            
//            NSArray* autoGeneratedExerciseViewControllers = [ExerciseViewController autoGeneratedExerciseViewControllersForVocabularyPearl:self.pearl];
//            
//            [autoGeneratedExerciseViewControllers makeObjectsPerformSelector:@selector(setExerciseNavigationController:) withObject:self];
//            
//            [_exerciseViewControllers addObjectsFromArray:autoGeneratedExerciseViewControllers];
//        }
    }
    else if (self.exercise) {
        
        ExerciseViewController* controller = [self _createExerciseViewControllerWithExercise:self.exercise];
        
        [_exerciseViewControllers addObject:controller];
    }
}


- (ExerciseViewController*) _createExerciseViewControllerWithExercise:(Exercise*) p_exercise {
    
    NSDictionary* exerciseDict = [ExerciseDictionary dictionaryForExercise:p_exercise];
    
    ExerciseViewController* controller = [ExerciseViewController viewControllerForExerciseDictionary:exerciseDict];

    controller.exerciseNavigationController = self;
    [self addChildViewController:controller];
    
    return controller;
}




#pragma mark - Managing Exercise View Controllers

- (BOOL) _hasNextExerciseWithIndex:(NSInteger) p_index {
    
    return p_index < _exerciseViewControllers.count;
}


- (void) _showExerciseWithIndex:(NSInteger) p_index animated:(BOOL) animated {
    
    // navigation bar
    self.navigationBar.progressBarFinished = NO;
    [self _updateNavigationBar];
    
    
    _currentExerciseViewController = _exerciseViewControllers[p_index];

    
    // set active cluster for progress manager

    [self _setActiveExerciseClusterIfNeeded];

    
    
    [self _showExerciseViewController:_currentExerciseViewController animated:animated];
    
    // title label and popup button
    [self _populateTitleContainer];
    
    // popup button
    [self _handlePopupButtonForController:_currentExerciseViewController];
    
//    // audio button
//    [self _updateAudioButton];

    NSString* instruction = [_currentExerciseViewController instruction];
    
    self.titleLabel.text = instruction;
    
//    ExerciseType type = [controller.exerciseDict[@"type"] integerValue];
//
//    if (type == VOCABFLOW && !instruction) {
//        
//        self.titleLabel.text = @"Höre das Wort an";
//    }
//    else if (type == MATPIC) {
//        
//        self.titleLabel.text = @"Finde die richtige Übersetzung";
//    }
    
    [self.titleLabel parseHTML];
}


- (void) _showExerciseViewController:(ExerciseViewController*) controller animated:(BOOL) animated {
    
    [self.exerciseContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.fullscreenContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.fullscreenNoScrollContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    switch (controller.layoutMode) {

        default:
        case ScrollingWithAdjust:  // typical scrolling exercise
        {
            [self.exerciseContainerView addSubview:controller.view];
            
            
            UIView* controllerView = controller.view;
            
            controllerView.translatesAutoresizingMaskIntoConstraints = NO;  // this is apparently necessary...
            
            [self.exerciseContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[controllerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(controllerView)]];
            [self.exerciseContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[controllerView]-(bottom)-|" options:0 metrics:@{@"bottom" : @(CONTENT_BOTTOM_MARGIN), @"top" : @(CONTENT_TOP_MARGIN)} views:NSDictionaryOfVariableBindings(controllerView)]];
            
            [self.fadeView bringSubviewToFront:self.contentWrapperView];
            [self.contentWrapperView bringSubviewToFront:self.scrollview];
            
            
//            [_currentExerciseViewController.view layoutIfNeeded];

            [self _setScrollSeparatorsVisible:YES];
            
        }
            break;

            
        case FullscreenWithAdjust:  // i.e. DIALOG
        {
            [self.fullscreenContainerView addSubview:controller.view];
            
            
            UIView* controllerView = controller.view;
            
            controllerView.translatesAutoresizingMaskIntoConstraints = NO;  // this is apparently necessary...
            
            [self.fullscreenContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[controllerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(controllerView)]];
            [self.fullscreenContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[controllerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(controllerView)]];
            
            
            [self.fadeView bringSubviewToFront:self.contentWrapperView];
            [self.contentWrapperView bringSubviewToFront:self.fullscreenContainerView];

            
//            [_currentExerciseViewController.view layoutIfNeeded];

            [self _setScrollSeparatorsVisible:YES];
        
        }
            break;
            
            
        case FullscreenWithoutAdjust:  // i.e. VOCABFLOW
        {
            [self.fullscreenNoScrollContainerView addSubview:controller.view];
            
            
            UIView* controllerView = controller.view;
            
            controllerView.translatesAutoresizingMaskIntoConstraints = NO;  // this is apparently necessary...
            
            [self.fullscreenNoScrollContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[controllerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(controllerView)]];
            [self.fullscreenNoScrollContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[controllerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(controllerView)]];
            
            
            [self.fadeView bringSubviewToFront:self.fullscreenNoScrollContainerView];
            
            
//            [_currentExerciseViewController.view layoutIfNeeded];

            [self _setScrollSeparatorsVisible:NO];
            
        }
            break;
            
    }
    

    
    // bottom button mode
    if (controller.canBeChecked) {
    
        [self _setBottomButtonModeCheck];
    }
    else {
        
        [self _setBottomButtonModeNext];
    }
    
    // hide/show bottom button
    if (controller.hidesBottomButtonInitially) {
        
        [self setBottomButtonHidden:YES animated:NO];
    }
    else {
        
        [self setBottomButtonHidden:NO animated:NO];
    }
    
    
    // DEV
    BOOL DEVskip = _DEVskipToScoreScreen;
    
    if (DEVskip) {
        
        [self _setBottomButtonModeNext];
        [self setBottomButtonHidden:NO animated:NO];
    }
    // /DEV
    
}


- (void) _showNextExercise {

    ++_currentExerciseIndex;

    
    [self _stopCurrentExerciseIfNeeded];
    
    
    if ([self _hasNextExerciseWithIndex:_currentExerciseIndex]) {
    
        [self _showExerciseWithIndex:_currentExerciseIndex animated:YES];
    }
    else {
        
        [self _showScoreScreen];
    }
}


- (void) _stopCurrentExerciseIfNeeded {
    
    if (_currentExerciseViewController) {
        
        [_currentExerciseViewController stopIfNeeded];
    }
}


- (void) _setActiveExerciseClusterIfNew:(ExerciseCluster*) exerciseCluster {

    [[UserProgressManager instance] setActiveExerciseClusterIfNew:exerciseCluster];
    
//    if ([[UserProgressManager instance] isNewExerciseCluster:exerciseCluster]) {
//        
//        [[UserProgressManager instance] setNewActiveExerciseCluster:exerciseCluster];
//    }
}



- (void) _updateAudioButton {
    
    ExerciseViewController* controller = _exerciseViewControllers[0];
    NSString* audioFile = controller.exerciseDict[@"audioFile"];
    
    self.audioButton.hidden = !(audioFile);
    

}





#pragma mark - Bottom Button

- (void) setBottomButtonHidden:(BOOL) hidden animated:(BOOL) animated {

    self.bottomButtonAreaHeightConstraint.constant = (hidden) ? 0 : BOTTOM_BUTTON_AREA_HEIGHT;
    [self.view setNeedsUpdateConstraints];

    if (animated) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:BOTTOM_BUTTON_ANIMATION_DURATION];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self.view layoutIfNeeded];
        [UIView commitAnimations];
    }
    else {
        
        [self.view layoutIfNeeded];
    }
}


- (void) _setBottomButtonModeCheck {
    
    _bottomButtonMode = Check;

    [self.bottomButton setTitle:BOTTOM_BUTTON_TITLE_CHECK forState:UIControlStateNormal];
}


- (void) _setBottomButtonModeNext {
    
    _bottomButtonMode = Next;
    
    [self.bottomButton setTitle:BOTTOM_BUTTON_TITLE_NEXT forState:UIControlStateNormal];
}



//- (void) _showBottomButtonCheck {
//    
//    [self.bottomButton setTitle:BOTTOM_BUTTON_TITLE_CHECK forState:UIControlStateNormal];
//    
//    [self setBottomButtonHidden:NO animated:YES];
//}
//
//
//- (void) _showBottomButtonNext {
// 
//    [self.bottomButton setTitle:BOTTOM_BUTTON_TITLE_NEXT forState:UIControlStateNormal];
//
//    [self setBottomButtonHidden:NO animated:YES];
//}


- (IBAction) actionBottomButton {
    
//    NSLog(@"scrollview: %@", NSStringFromCGRect(exerciseContainerView.superview.frame));
//    NSLog(@"exerciseContainerView: %@", NSStringFromCGRect(exerciseContainerView.frame));
////    NSLog(@"exercise view: %@", NSStringFromCGRect([exerciseContainerView.subviews[0] frame]));
//
//    NSLog(@"constraints: %@", self.view.constraints);
//    
//    NSLog(@"width constraint: %@", self.widthConstraint);
//    
//    NSLog(@"isPart: %d", ([self.view.constraints containsObject:self.widthConstraint]));
//    
//    UIView* selfView = self.view;
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[exerciseContainerView(selfView)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(exerciseContainerView, selfView)]];
//
//    [self.view setNeedsLayout];
//    [self.view layoutIfNeeded];

    if (_bottomButtonMode == Check) {

        [self _actionCheck];
    }
    else {
        
        [self _actionNext];
    }
}


- (void) _actionCheck {
    
    NSLog(@"check");
    
    [self.view endEditing:YES];
    
    ExerciseViewController* controller = _exerciseViewControllers[_currentExerciseIndex];
    
    if (!controller.checked) {
        
        [controller check];
        
        [self _setBottomButtonModeNext];
    }
    
    BOOL wasLastController = (_currentExerciseIndex == _exerciseViewControllers.count - 1);
    
    if (wasLastController) {
        
        NSLog(@"was last controller -> updating nav bar to finished");
        
        self.navigationBar.progressBarFinished = YES;
        [self _updateNavigationBar];  // force update
    }
    
//    [self setBottomButtonHidden:YES animated:NO];
}


- (void) _actionNext {
    
    NSLog(@"next");
    
    BOOL exerciseHandlesNextButton = [_currentExerciseViewController shouldHandleNextButton];
    
    if (exerciseHandlesNextButton) {
        
        [_currentExerciseViewController handleNextButton];
    }
    else {
    
        [self _showNextExercise];
    }
}




#pragma mark - Scroll Separators

- (void) _setScrollSeparatorsVisible:(BOOL) visible {
    
//    BOOL scrollViewNeedsScrolling = ({
//        
//        BOOL needsScrolling = NO;
//        
//        if (_currentExerciseViewController.layoutMode == ScrollingWithAdjust) {
//            
//            CGFloat contentHeight = _currentExerciseViewController.view.frame.size.height + CONTENT_TOP_MARGIN + CONTENT_BOTTOM_MARGIN;
//            needsScrolling = (self.scrollview.frame.size.height < contentHeight);
//        }
//        else if (_currentExerciseViewController.layoutMode == FullscreenWithAdjust) {
//            
//            needsScrolling = YES;
//        }
//        
//        needsScrolling;
//    });
//    
    BOOL reallyVisible = visible;
    
    _scrollSeparatorTop.hidden = !reallyVisible;
    _scrollSeparatorBottom.hidden = !reallyVisible;
}





#pragma mark - Keyboard

- (void) _registerKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillChangeFrame:) name:UIKeyboardWillHideNotification object:nil];
}


- (void) _unregisterKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) _keyboardWillChangeFrame:(NSNotification*) notification {
    
    
    NSDictionary* userInfo = notification.userInfo;
    
        NSLog(@"%@", userInfo);
    
    //    CGRect newFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    
    
    CGRect endFrame = [self.view convertRect:[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    CGFloat height = MAX(self.view.frame.size.height - endFrame.origin.y, 0);
    
    //    NSLog(@"new keyboard height relative to self.view: %f", height);

    NSLog(@"keyboardWillChangeFrame (height: %f, duration: %f)", height, duration);

    
    BOOL visible = (height > 0);
    
    self.keyboardHeightConstraint.constant = height - MAX(self.bottomButtonAreaHeightConstraint.constant, 0);
    [self.view setNeedsUpdateConstraints];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
    
    
    [_currentExerciseViewController handleKeyboardDidChangeFrameVisible:visible];
}






#pragma mark - Popup

- (void) actionPopupButton {
    
    ExerciseViewController* controller = _exerciseViewControllers[self.currentExerciseIndex];
    NSString* popupFile = [self _popupFileForController:controller];
    
    [self _presentPopupWithFile:popupFile];
}


- (void) _presentPopupWithFile:(NSString*) popupFile {
    
    _popupViewController = [[ExercisePopupViewController alloc] initWithFile:popupFile];
    Exercise* theExercise = _currentExerciseViewController.exerciseDict[@"exerciseObject"];
//    Course* course = [[ContentDataManager instance] courseForExerciseCluster:theExercise.cluster];
    Lesson* lesson = [[ContentDataManager instance] lessonForExerciseCluster:theExercise.cluster];
    _popupViewController.lesson = lesson;
    __weak ExerciseNavigationController* weakSelf = self;

    _popupViewController.closeBlock = ^{
    
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            
            _presentingPopup = NO;
        }];
    };
    
//    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    _presentingPopup = YES;
    
    [self presentViewController:_popupViewController animated:YES completion:^{
        
    }];
}



#pragma mark - Intro Screen

- (void) openInNavigationController:(UINavigationController*) navigationController withIntroScreen:(BOOL) withIntroScreen {
 
    if (withIntroScreen) {

        _introViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
        Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:self.exerciseCluster];
        _introViewController.pearl = pearl;
        _introViewController.view.accessibilityIdentifier = @"Intro screen - view";
        __weak NavigationController* weakController = (NavigationController*)navigationController;
        __weak ExerciseNavigationController* weakSelf = self;
        __weak ExerciseIntroViewController* weakIntro = _introViewController;
        
//        __weak ModalStackViewController* weakModalStackViewController = _modalStackViewController;

        
        
//        UIViewController* (^findTopPresentingViewController)() = ^UIViewController* () {
//          
//            UIViewController* presentingViewController = navigationController;
//            
//            while (presentingViewController.presentedViewController) {
//                
//                presentingViewController = presentingViewController.presentedViewController;
//                
//                
//                // fade out Score Screen when presenting Intro Screen over it
//                
//                if ([presentingViewController isKindOfClass:[ExerciseScoreViewController class]]) {
//                    
//                    [(ExerciseScoreViewController*)presentingViewController fadeOut];
////                    ((ExerciseScoreViewController*)presentingViewController).view.alpha = 0.0f;
//                }
////                else if ([presentingViewController isKindOfClass:[ShopPopupViewController class]]) {
////                    
////                    ((ShopPopupViewController*)presentingViewController).view.alpha = 0.0f;
////                }
//            }
//            
//            return presentingViewController;
//        };
        
        
        
//        UIViewController* presentingViewController = findTopPresentingViewController();
//        void(^secondDismissBlock)() = ^void() {};
        
//        if (navigationController.presentedViewController) {
//            
//            presentingViewController = navigationController.presentedViewController;
//            
////            secondDismissBlock = ^void() {
////            
////                [weakController dismissViewControllerAnimated:NO completion:^{
////                    
////                }];
////            };
//        }
        
        
//        __weak UIViewController* weakPresenter = presentingViewController;
        
        
        
        
        
        // DEV
        __block BOOL DEVskip = _DEVskipToScoreScreen;
        DEVskip = NO;
        // /DEV
        
        _introViewController.closeBlock = ^{
            
            [[ExerciseNavigationController weakModalStackViewController] dismissStackWithCompletionBlock:^{
               
                
                if (DEVskip) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf _DEVSkipToScoreScreen];
                    });
                }
                else {
                    
                    [weakSelf.currentExerciseViewController start];
                }
            }];
            
//            [weakController dismissViewControllerAnimated:YES completion:^{
//
////                secondDismissBlock();
//                
//                // DEV
//                
//                if (DEVskip) {
//                    
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [weakSelf _DEVSkipToScoreScreen];
//                    });
//                }
//                else {
//                    
//                    [weakSelf.currentExerciseViewController start];
//                }
//                
//                // /DEV
//
//            }];
        };

        _introViewController.backBlock = ^{
            
            [weakController popViewControllerAnimated:NO];        // ! animated=no is temporary until a better way is implemented. Having YES will animate the modal view controller together with the pushed out viewcontroller, so there is no fade out, but it is pushed out to the right
            
//            [weakController dismissViewControllerAnimated:YES completion:^{
//                
////                secondDismissBlock();
//            }];

            [[ExerciseNavigationController weakModalStackViewController] dismissStackWithCompletionBlock:^{
                
                
            }];
            
        };

        

        
        void(^presentIntroBlock)() = ^{
            
            [[ExerciseNavigationController weakModalStackViewController] addViewController:weakIntro withConfiguration:@{} completionBlock:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakController pushViewController:self animated:NO];  // ! also animated = no (new animation?)
                });
            }];
            
        };
        
        


        
        
        BOOL modalStackIsPresented = [[ExerciseNavigationController weakModalStackViewController] isPresented];
        
        
        if (!modalStackIsPresented) {
            
            [navigationController presentViewController:[ExerciseNavigationController weakModalStackViewController] animated:NO completion:^{
                
                presentIntroBlock();
            }];
        }
        else {
            
            presentIntroBlock();
        }
        
        
        
//        [presentingViewController presentViewController:_introViewController animated:YES completion:^{
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                [weakController pushViewController:self animated:NO];  // ! also animated = no (new animation?)
//            });
//            
////            [weakController forcePushViewController:self];
//        }];
    }
    
    else {
        
        [navigationController pushViewController:self animated:YES];
        
        UIView* theView = self.view;  // force viewDidLoad
        
        [_currentExerciseViewController start];
    }
}




//
//
//#pragma mark - Audio
//
//- (IBAction) actionAudioButton {
//
//    NSLog(@"audio");
//    
//    [_player playExerciseAudio];
//}




#pragma mark - User Progress

- (void) _setActiveExerciseClusterIfNeeded {
    
    ExerciseViewController* controller = _currentExerciseViewController;
    ExerciseCluster* exerciseCluster = nil;
    
    
    // case exerciseDict
    
    if (controller.exerciseDict) {
    
        Exercise* theExercise = controller.exerciseDict[@"exerciseObject"];
        exerciseCluster = theExercise.cluster;
    }
    
    
    NSAssert(exerciseCluster, @"");
    
    [[UserProgressManager instance] setActiveExerciseClusterIfNew:exerciseCluster];
}




#pragma mark - Score Screen

- (void) _showScoreScreen {
    
    NSInteger score;
    NSInteger maxScore;
    
    // get score
    
    [[UserProgressManager instance] finalScoreForActivePearlScore:&score maxScore:&maxScore];
    
    //
    
    
    // calculate next pearl
    
    [self _calculateNextPearl];
    
    //
    
    
    // update user lesson
    
    [self _updateUserLessonWithLesson:_nextPearl.lesson];
    
    //

    
    
    
    
//    _modalStackViewController = [self _modalStackViewController];
    
//    __weak ModalStackViewController* weakModalStackViewController = _modalStackViewController;
    
    
    
    
    Lesson* lesson = [[ContentDataManager instance] lessonForExerciseCluster:self.exerciseCluster];
    BOOL showCloseButton = (_nextPearl.lesson == lesson);
    
    _scoreViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScoreViewController"];
    _scoreViewController.score = score;
    _scoreViewController.maxScore = maxScore;
    _scoreViewController.showCloseButton = showCloseButton;
    _scoreViewController.view.accessibilityIdentifier = @"Score Screen - view";
    __weak UINavigationController* weakController = self.navigationController;
//    __weak UITabBarController* weakTab = self.navigationController.tabBarController;
    __weak ExerciseNavigationController* weakSelf = self;
    
    _scoreViewController.backBlock = ^{
        
//        [weakController popViewControllerAnimated:YES];
        [weakController popViewControllerAnimated:NO];
        
//        [weakController dismissViewControllerAnimated:YES completion:^{
//        [weakController dismissViewControllerAnimated:YES completion:^{
//      
//        }];
        
        [[ExerciseNavigationController weakModalStackViewController] dismissStackWithCompletionBlock:^{
            
            
        }];
    };

    
    
//    __weak __block UIViewController* weakPresentingViewController = _scoreViewController;
    
    
    
    // new block: present shop if no active sub
    
    BOOL hasActiveSubscription = [[SubscriptionManager instance] hasActiveSubscription];
    
//    hasActiveSubscription = YES;
    
    void(^presentShopIfNoActiveSub)(void (^)()) = ^void(void (^proceedBlock)()){
        
        if (hasActiveSubscription) {
            
            proceedBlock();
        }
        else {
            
            // 1. create Shop as popup VC
            // 2. use as presenting VC: weakPresentingViewController
            // 3. set _presentingShop
            // 4. set closeBlock and purchaseCompleteBlock to proceedBlock
            // 5. do stuff with alpha values of the underlying modal VC (parent)
            
            ShopPopupViewController* shopController = [[ShopPopupViewController alloc] init];
            shopController.closeBlock = proceedBlock;
            shopController.view.accessibilityIdentifier = @"Shop - view";
            
//            [weakPresentingViewController presentViewController:shopController animated:YES completion:^{
//                
//                _presentingShop = YES;
//                weakPresentingViewController.view.alpha = 0.0f;  // is this enough?
//            }];
            
            _presentingShop = YES;
            
            [[ExerciseNavigationController weakModalStackViewController] addViewController:shopController withConfiguration:@{}];
        }
    };
    
    
    //--
    
    
    
    void(^nextBlock)() = ^{
        
        presentShopIfNoActiveSub(^{
        
            [weakSelf _switchToNextPearlIfWithinSameLessonWithCompletionBlock:^{

            }];
        
        });
        
    };
    

    
    BOOL courseCompleted = (_nextPearl.lesson.course != lesson.course);
    
//    __weak ExerciseScoreViewController* weakScoreViewController = _scoreViewController;
    
    if (courseCompleted) {

        NSString* nextCourseTitle = _nextPearl.lesson.course.title;

        _scoreViewController.nextBlock = ^{
          
            CourseCompletionViewController* courseController = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"CourseCompletionViewController"];
            courseController.title = nextCourseTitle;
            courseController.nextBlock = nextBlock;
//            courseController.view.accessibilityIdentifier = @"Course completion - view";
            
//            weakPresentingViewController = courseController;
            
//            [weakScoreViewController presentViewController:courseController animated:YES completion:^{
//                
//                _presentingCourseCompletionScreen = YES;
//                weakScoreViewController.scoreView.alpha = 0.0f;
//                weakScoreViewController.view.alpha = 0.0f;
//            }];
            
            _presentingCourseCompletionScreen = YES;
            
            [[ExerciseNavigationController weakModalStackViewController] addViewController:courseController withConfiguration:@{}];
        };
    }
    else {
        
        _scoreViewController.nextBlock = nextBlock;
    }

        
    
    _scoreViewController.restartBlock = ^{
        
        presentShopIfNoActiveSub(^{
        
            [weakSelf _restartPearlWithCompletionBlock:^{
                
            }];

        });
        
    };

    
//    [self.navigationController presentViewController:_scoreViewController animated:YES completion:^{
//    
//    }];

    [self.navigationController presentViewController:[ExerciseNavigationController weakModalStackViewController] animated:NO completion:^{
        
        [[ExerciseNavigationController weakModalStackViewController] addViewController:_scoreViewController withConfiguration:@{}];
    }];
    
}




#pragma mark - Switch to next pearl LOGIC

- (void) _calculateNextPearl {
    
    Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:self.exerciseCluster];
    _nextPearl = [[UserProgressManager instance] nextPearlForPearl:pearl];
}


- (void) _switchToNextPearlIfWithinSameLessonWithCompletionBlock:(void(^)()) completionBlock {
    
    [self _populateNavigationControllerStackForPearl:_nextPearl withCompletionBlock:completionBlock];
}


- (void) _restartPearlWithCompletionBlock:(void(^)()) completionBlock {

//    [[UserProgressManager instance] startNextRunForLesson:lesson];
    
    Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:self.exerciseCluster];
    _nextPearl = pearl;
    
    [self _populateNavigationControllerStackForPearl:_nextPearl withCompletionBlock:completionBlock];
}


- (void) _populateNavigationControllerStackForPearl:(Pearl*) thePearl withCompletionBlock:(void(^)()) completionBlock {
    
    
    Pearl* pearl = [[ContentDataManager instance] pearlForExerciseCluster:self.exerciseCluster];
    BOOL changeLessonMenu = thePearl.lesson.id != pearl.lesson.id;
    BOOL changeCourseMenu = thePearl.lesson.course.id != pearl.lesson.course.id;
    
    BOOL controllerHasCourseMenu = self.navigationController.viewControllers.count >= 3;
  
    
//    NSMutableArray* viewControllerStack = [self.navigationController.viewControllers mutableCopy];
    
    __weak NavigationController* weakController = (NavigationController*)self.navigationController;

    
    void(^popVCBlock)() = ^void() {
      
        [weakController popViewControllerAnimated:NO];
    };
    
    
    
    
    // step 1: pop ExerciseNavigationViewController (self)

    popVCBlock();

//    [self.navigationController popViewControllerAnimated:NO];  // top is now the lesson menu, pearls
    
//    [viewControllerStack removeLastObject];
    
    
    
    
//    NSLog(@"%@", weakController.viewControllers);
    
//    NSAssert(weakController.topViewController && [weakController.topViewController isKindOfClass:[PearlViewController class]], @"");
    
        
        
    // step 2: change lesson menu (and more) if needed

    
    if (changeLessonMenu) {
        
        // pop lesson menu
        
//        [self.navigationController popViewControllerAnimated:NO];  // top is now the course menu, lessons
        
        popVCBlock();
        
//        [viewControllerStack removeLastObject];
        
        
        // step 3: change course menu if needed
        
        if (changeCourseMenu && controllerHasCourseMenu) {
            
            // pop course menu
            
            popVCBlock();
            
//            [self.navigationController popViewControllerAnimated:NO];  // top is now the language menu, courses (ROOT)
            
//            [viewControllerStack removeLastObject];
            
            // push new course menu

            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIViewController* topViewController = weakController.topViewController;
                //            NSAssert(topViewController && [topViewController isKindOfClass:[CourseViewController class]], @"");
                CourseViewController* controller = (CourseViewController*)topViewController;
                [controller pushLessonMenuForCourse:thePearl.lesson.course];
            });
        }
        
        
        // push new lesson menu
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIViewController* topViewController = weakController.topViewController;
            
            if (topViewController) {
            
                //        NSAssert(topViewController && [topViewController isKindOfClass:[LessonViewController class]], @"");
                LessonViewController* controller = (LessonViewController*)topViewController;
                [controller pushPearlMenuForLesson:thePearl.lesson];
            }
            else {
                
                PearlViewController* controller = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Pearl Menu"];
                controller.lesson = thePearl.lesson;
                [weakController pushViewController:controller animated:NO];
            }
        });
        
    }

//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [self.navigationController setViewControllers:viewControllerStack animated:NO];
//        
//    });
    
    

    
    
    // step 3: push the ExerciseNavigation
    
//    NSAssert(self.navigationController.topViewController && [self.navigationController.topViewController isKindOfClass:[PearlViewController class]], @"");

    
    if (!changeLessonMenu) {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            PearlViewController* controller = (PearlViewController*)weakController.topViewController;
            //        ExerciseCluster* exerciseCluster = [[ContentDataManager instance] firstClusterForPearl:thePearl];
            ExerciseCluster* exerciseCluster = [[UserProgressManager instance] nextIncompleteExerciseClusterForPearlInsideSamePearl:thePearl];
            [controller pushExerciseNavigationControllerForExerciseCluster:exerciseCluster withIntroScreen:YES];
            
        });
        
    }
    else {
        
//        __weak ModalStackViewController* weakStackController = _modalStackViewController;
        
        __weak ExerciseNavigationController* weakSelf = self;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [[ExerciseNavigationController weakModalStackViewController] dismissStackWithCompletionBlock:^{
                
                NSLog(@"Stack dismissed.");
            }];
            
//            if (_presentingShop) {
//
//                NSLog(@"presenting shop");
//                
//                UIViewController* presentingViewController = (ExerciseScoreViewController*)weakController.presentedViewController;
//
//                // case 1: shop is presented by score screen
//                // case 2: shop is presented by course completion screen
//                
//                if (_presentingCourseCompletionScreen) {
//                    
//                    presentingViewController = (UIViewController*) presentingViewController.presentedViewController;
//                    
//                    NSLog(@"course completion screen dismissing shop");
//                }
//                else {
//                    
//                    NSLog(@"score controller dismissing shop");
//                }
//                
//                
//                [presentingViewController dismissViewControllerAnimated:YES completion:^{
//                    
//                    NSLog(@"... dismissed");
//                    
//                    _presentingShop = NO;
//                }];
//            }
//            
//            if (_presentingCourseCompletionScreen) {
//                
//                NSLog(@"presenting course completions screen");
//                
//                ExerciseScoreViewController* scoreController = (ExerciseScoreViewController*)weakController.presentedViewController;
//                
//                NSLog(@"score controller dismissing course completion screen");
//                
//                [scoreController dismissViewControllerAnimated:YES completion:^{
//                    
//                    NSLog(@"... dismissed");
//                    NSLog(@"dismissing score controller not animated");
//                    
//                    _presentingCourseCompletionScreen = NO;
//                    
//                    [weakController dismissViewControllerAnimated:NO completion:^{
//                        
//                        
//                    }];
//                }];
//                
//            }
//            else {
//                
//                [weakController dismissViewControllerAnimated:YES completion:^{
//                    
//                }];
//            }
            
        });
        
    }

    
    dispatch_async(dispatch_get_main_queue(), completionBlock);

    
    
    
}



#pragma mark - ModalStackViewController


+ (ModalStackViewController*) weakModalStackViewController {
    
    __weak ModalStackViewController* controller = [ModalStackViewController instanceWithName:@"modalStack"];
    
    return controller;
}




#pragma mark - Update User Lesson (Deine Lektion)

- (void) _updateUserLessonWithLesson:(Lesson*) lesson {
    
    [[UserProgressManager instance] setCurrentUserLesson:lesson];
}



#pragma mark - Delegates

- (void) exerciseNavigationBarDidReceiveCloseCommand:(ExerciseNavigationBar *)navigationBar {
    
//    [_currentExerciseViewController stop];
    
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - Dealloc

- (void) dealloc {
    
    [self _unregisterKeyboardNotifications];
}





#pragma mark - DEV

- (void) _DEVSkipToScoreScreen {
    
    [self _DEVAssignDummyScoreForAllExercises];
    
    [self _showScoreScreen];
}


- (void) _DEVAssignDummyScoreForAllExercises {
    
    for (ExerciseViewController* controller in _exerciseViewControllers) {
        
        Exercise* theExercise = controller.exerciseDict[@"exerciseObject"];
        ExerciseCluster* exerciseCluster = theExercise.cluster;
        
        [[UserProgressManager instance] setActiveExerciseClusterIfNew:exerciseCluster];
        [[UserProgressManager instance] setScore:5 ofMaxScore:5 forExercise:theExercise];
    }
}






@end
