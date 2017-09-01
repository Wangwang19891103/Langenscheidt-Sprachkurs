//
//  DialogViewController2.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 26.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "DialogViewController2.h"
#import "ContentDataManager.h"
#import "PearlTitle.h"
#import "ExerciseTypes.h"
#import "ExerciseTextField.h"
#import "NSMutableAttributedString+HTML.h"
#import "UIScrollView+NoScroll.h"
#import "CGExtensions.h"
#import "ExerciseTypes.h"
#import "ContentDataManager.h"


#define SCROLL_TO_VISIBLE_INSETS                UIEdgeInsetsMake(20, 20, 20, 20)



@implementation DialogViewController2

@synthesize pearl;


- (void) setPearl:(Pearl *)p_pearl {
    
    pearl = p_pearl;
    
    _dialogs = [[ContentDataManager instance] dialogsForPearl:pearl];
    
//    Dialog* firstDialog = _dialogs[0];
//    NSString* audioFile = firstDialog.audioFile;
//    NSURL* fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:audioFile ofType:@"mp3"]];
    
    //    assert(audioFile);
    
//    NSLog(@"audioFile: %@", audioFile);
    
//    _player = [[AudioPlayer alloc] initWithURL:fileURL times:@[]];
//    _player.delegate = self;
//    _player.fadeInDuration = 0.3;
//    _player.fadeOutDuration = 0.3;

    _feeder = [[DialogFeeder alloc] initWithDialogs:_dialogs];
    _feeder.delegate = self;
    
}


- (void) keyboardWillChangeFrame:(NSNotification*) notification {
    
    NSLog(@"keyboardWillChangeFrame");
    
    NSDictionary* userInfo = notification.userInfo;
    
    //    NSLog(@"%@", userInfo);
    
    //    CGRect newFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    
    
    CGRect endFrame = [self.view convertRect:[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    CGFloat height = MAX(self.view.frame.size.height - endFrame.origin.y, 0);
    
    //    NSLog(@"new keyboard height relative to self.view: %f", height);
    
    
    self.bottomDummyHeightConstraint.constant = height;
    [self.view setNeedsUpdateConstraints];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
    
    [self _scrollCurrentTextFieldToVisible];
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    _viewFinishedLoading = YES;
    
    self.navigationItem.title = [PearlTitle titleForPearl:pearl];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.contentStackView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.prototypeTextContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    [_feeder scheduleNextBatchWhenReady];
}


#pragma mark - Dialog Items



- (void) _handleDialogFeederWillPlayNextPartWithIndex:(NSInteger) index {

    [self _insertNextItemWithIndex:index];
}


- (void) _handleDialogFeederDidEndPlayingPartWithIndex:(NSInteger) index {
    
    if (![self _textFieldIsFirstResponder]) {
    
        [self _skipToNextTextField];
    }
}


- (ExerciseTextField*) _currentTextFieldFirstResponder {
    
    for (ExerciseTextField* textField in _currentTextView.textFields) {
        
        if ([textField isFirstResponder]) {

            return textField;
        }
    }
    
    return nil;
}


- (BOOL) _textFieldIsFirstResponder {
    
    return [self _currentTextFieldFirstResponder] != nil;
}


- (BOOL) _currentTextFieldsAnswered {
    
    BOOL allAnswered = YES;
    
//    NSLog(@"count: %ld", _currentTextView.textFields.count);
    
    for (ExerciseTextField* textField in _currentTextView.textFields) {
        
//        NSLog(@"solutionState: %ld", textField.solutionState);
        
        if (textField.solutionState == ExerciseControlSolutionStateNotChecked) {
            
            allAnswered = NO;
            break;
        }
    }
    
    return allAnswered;
}



#pragma mark - Visual Items

- (void) _insertNextItemWithIndex:(NSInteger) index {
    
    Dialog* dialog = _dialogs[index];
    
    UIView* item = [self _itemForDialog:dialog];
    [self _scheduleScrollToVisibleOnView:item];
    
    [self.contentStackView addSubview:item];
    
    [self.contentStackView setNeedsUpdateConstraints];
    [self.contentStackView updateConstraintsIfNeeded];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
}


- (void) _scheduleScrollToVisibleOnView:(UIView*) view {
    
    _bottomMostItem = view;
    _needsScrollToVisible = YES;
}


- (void) _skipToNextTextField {
    
    uint nextTextFieldIndex = 0;
    
    // find active responder if available
    
    for (uint i = 0; i < _currentTextView.textFields.count; ++i) {
        
        UITextField* textField = _currentTextView.textFields[i];
        
        if ([textField isFirstResponder]) {
            
            nextTextFieldIndex = i + 1;
            break;
        }
    }
    
    if (nextTextFieldIndex < _currentTextView.textFields.count) {
        
        // make next textfield first responder
        
        NSLog(@"Skipping to next textfield with index %d", nextTextFieldIndex);
        
        [_currentTextView.textFields[nextTextFieldIndex] becomeFirstResponder];
    }
    else {
        
        // resign first responder
        
        NSLog(@"Resigning first responder");
        
        [self.view endEditing:YES];
    }
}


-  (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    [self _scrollToVisibleIfNeeded];
}


- (void) _scrollToVisibleIfNeeded {
    
    if (!_needsScrollToVisible) return;

    _needsScrollToVisible = NO;

    [self.contentStackView setNeedsLayout];  // force layout in order to receive frame of bottom most item
    [self.contentStackView layoutIfNeeded];
    [self.scrollView setNeedsLayout];        // also force scrollview layout or it wont have the proper content size from autolayout
    [self.scrollView layoutIfNeeded];
    
    [self _scrollViewToVisible:_bottomMostItem];

//    CGRect itemRect = [self.scrollView convertRect:_bottomMostItem.bounds fromView:_bottomMostItem];
//    
//    NSLog(@"scrolling to rect: %@", NSStringFromCGRect(itemRect));
//    
//    [self.scrollView scrollRectToVisible2:itemRect animated:YES];
}


- (UIView*) _itemForDialog:(Dialog*) dialog {
    
    UIView* containerView = [self _newContainerView];
    ExerciseTextView2* textView = [self _newTextView];
    textView.string = dialog.textLang1;
    [textView createView];
    
    [self _assignInputTypesForTextFields:textView.textFields withDialog:dialog];
    
    _currentTextView = textView;
    [textView.textFields makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    UITextView* language2textView = [self _newLanguage2TextView];
    language2textView.text = dialog.textLang2;
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:language2textView.attributedText];
    [attributedString parseHTML];
    language2textView.attributedText = attributedString;
    
    [containerView addSubview:textView];
    [containerView addSubview:language2textView];
    
//    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textView]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(textView)]];
//    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[textView]-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(textView)]];
    
    return containerView;
}


- (void) _assignInputTypesForTextFields:(NSArray*) textFields withDialog:(Dialog*) dialog {
    
    NSArray* IDs = [dialog.vocabularyIDs componentsSeparatedByString:@","];
    
    NSArray* possibleTypesWithoutDND = @[
                                         @(ExerciseInputTypeStandard),
                                         @(ExerciseInputTypeScrambledLetters),
                                         ];
    NSArray* possibleTypesWithDND = @[
                                      @(ExerciseInputTypeStandard),
                                      @(ExerciseInputTypeScrambledLetters),
                                      @(ExerciseInputTypeDragAndDrop)
                                      ];

    
    for (uint i = 0; i < textFields.count; ++i) {
        
        uint vocabularyID = -1;
        
        if (i < IDs.count) {
            
            NSString* IDString = IDs[i];
            
            if (IDString.length > 0) {
                
                vocabularyID = (int)[IDString integerValue];
            }
        }
        
        NSArray* possibleTypes = (vocabularyID != -1) ? possibleTypesWithDND : possibleTypesWithoutDND;
        
        uint typeIndex = arc4random() % possibleTypes.count;
        
        ExerciseInputType type = [possibleTypes[typeIndex] integerValue];
        
        ExerciseTextField* textField = textFields[i];
        textField.inputType = type;
        
        if (textField.inputType == ExerciseInputTypeDragAndDrop) {
            
            [self _expandSolutionsForTextField:textField withVocabularyID:vocabularyID];
        }
        
        NSLog(@"Assigning input type: %ld", textField.inputType);
    }
}


- (void) _expandSolutionsForTextField:(ExerciseTextField*) textField withVocabularyID:(uint) vocabularyID {
    
    NSArray* vocabularies = [[ContentDataManager instance] vocabulariesInSameChunkAsVocabularyWithID:vocabularyID];
    
    NSMutableArray* solutions = [NSMutableArray array];
    
    for (Vocabulary* vocabulary in vocabularies) {

        if (vocabulary.id == vocabularyID) {

            [solutions insertObject:vocabulary.textLang1 atIndex:0];
        }
        else {

            [solutions addObject:vocabulary.textLang1];
        }
    }
    
    textField.solutionStrings = solutions;
}


//- (ExerciseTextView2*) _newTextView {
//    
//    ExerciseTextView2* textView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.prototypeTextView]];
//    textView.fontName = self.prototypeTextView.fontName;
//    textView.fontSize = self.prototypeTextView.fontSize;
//    textView.fontColor = self.prototypeTextView.fontColor;
////    textView.textLayerAdjustmentY = self.prototypeTextView.textLayerAdjustmentY;
//    textView.lineSpacing = self.prototypeTextView.lineSpacing;
//    textView.textFieldHeight = self.prototypeTextView.textFieldHeight;
////    textView.textFieldAdjustmentWidth = self.prototypeTextView.textFieldAdjustmentWidth;
//    textView.textFieldBackgroundColor = self.prototypeTextView.textFieldBackgroundColor;
//    textView.textFieldBorderColor = self.prototypeTextView.textFieldBorderColor;
//    textView.textFieldBackgroundColorCorrect = self.prototypeTextView.textFieldBackgroundColorCorrect;
//    textView.textFieldBackgroundColorWrong = self.prototypeTextView.textFieldBackgroundColorWrong;
//    textView.textFieldBorderColorSelected = self.prototypeTextView.textFieldBorderColorSelected;
//    textView.inputType = ExerciseInputTypeStandard;
//    
//    return textView;
//}

- (ExerciseTextView2*) _newTextView {
    
    ExerciseTextView2* textView = [[ExerciseTextView2 alloc] init];
    textView.inputType = ExerciseInputTypeStandard;
    textView.layoutMargins = UIEdgeInsetsZero;
    
    if (textView.inputType == ExerciseInputTypeDragAndDrop) {
        
        textView.generateSharedSolutions = YES;
    }
    
    return textView;
}


- (StackView*) _newContainerView {
    
    StackView* view = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.prototypeTextContainerView]];
    view.spacing = self.prototypeTextContainerView.spacing;
    
    return view;
}


- (UITextView*) _newLanguage2TextView {
    
    UITextView* textView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.prototypeLanguage2TextView]];
    textView.textContainerInset = self.prototypeLanguage2TextView.textContainerInset;
    textView.textContainer.lineFragmentPadding = self.prototypeLanguage2TextView.textContainer.lineFragmentPadding;
    textView.font = self.prototypeLanguage2TextView.font;
    textView.selectable = NO;
    
    return textView;
}



#pragma mark - Audio Items

//- (NSArray*) timesFromString:(NSString*) string {
//    
//    NSString* timeString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];  // kill spaces
//    NSArray* comps = [timeString componentsSeparatedByString:@"-"];
//    NSRange rangeOfColon = [string rangeOfString:@":"];
//    NSAssert(rangeOfColon.location != NSNotFound, @"...");
//    
//    NSMutableArray* times = [NSMutableArray array];
//    
//    for (NSString* comp in comps) {
//        
//        NSString* minuteString = [comp substringWithRange:NSMakeRange(0, rangeOfColon.location)];
//        NSString* secondString = [comp substringWithRange:NSMakeRange(rangeOfColon.location + 1, comp.length - rangeOfColon.location - 1)];
//        
//        CGFloat minutes = [minuteString floatValue];
//        CGFloat seconds = [secondString floatValue];
//        
//        CGFloat totalMilliseconds = (minutes * 60 + seconds) * 1000;
//        
//        CMTime time = CMTimeMake(totalMilliseconds, 1000);
//        
//        [times addObject:[NSValue valueWithCMTime:time]];
//    }
//    
//    return times;
//}


//- (void) audioPlayerDidFinishLoadingAsset:(AudioPlayer *)player {
//
//    _playerAssetLoaded = YES;
//    
//    [self _scheduleNextItem];
//}


//- (void) audioPlayerDidEndPlaying:(AudioPlayer *)player {
//    
//    [self _scheduleNextItem];
//}


//- (void) audioPlayerDidEndPlayingPart:(AudioPlayer *)player {
//    
//    NSLog(@"didEndPlayingPart");
//    
//    ++_currentAudioIndex;
//
//    [self _scheduleNextItem];
//}


- (void) dialogFeeder:(DialogFeeder *)feeder willPlayNextPartWithIndex:(NSInteger)index {

    [self _handleDialogFeederWillPlayNextPartWithIndex:index];
    
}


- (void) dialogFeeder:(DialogFeeder *)feeder didEndPlayingPartWithIndex:(NSInteger)index {
    
    [self _handleDialogFeederDidEndPlayingPartWithIndex:index];
}


- (BOOL) dialogFeederReadyForNextBatch:(DialogFeeder *)feeder {
    
    return _viewFinishedLoading && [self _currentTextFieldsAnswered];
}


- (void) dialogFeederFinishedAllBatches:(DialogFeeder *)feeder {
    
    NSLog(@"FINISHED");
}


- (void) _scrollCurrentTextFieldToVisible {

    [self scrollTextFieldToVisible:[self _currentTextFieldFirstResponder]];
}


- (void) scrollTextFieldToVisible:(ExerciseTextField*) textField {
    
//    [self.contentStackView setNeedsLayout];  // force layout in order to receive frame of bottom most item
//    [self.contentStackView layoutIfNeeded];
//    [self.scrollView setNeedsLayout];        // also force scrollview layout or it wont have the proper content size from autolayout
//    [self.scrollView layoutIfNeeded];

    
    UIView* surroundingView = textField.scrollContainerView.superview;
    
    [self _scrollViewToVisible:surroundingView];
    
    
//    [self _scheduleScrollToVisibleOnView:surroundingView];
}


- (void) _scrollViewToVisible:(UIView*) theView {
    
    CGRect rect = [self.scrollView convertRect:theView.bounds fromView:theView];
    rect = CGRectOutset(rect, SCROLL_TO_VISIBLE_INSETS);
    
    NSLog(@"scrolling rect to visible: %@", NSStringFromCGRect(rect));
    
    [self.scrollView scrollRectToVisible2:rect animated:YES];
}



#pragma  mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
    NSLog(@"textFieldDidBeginEditing");
    
//    [self scrollTextFieldToVisible:(ExerciseTextField*)textField];
    
    [(ExerciseTextField*)textField setSelected:YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [(ExerciseTextField*)textField check];
    [(ExerciseTextField*)textField setSelected:NO];
    
    if (((ExerciseTextField*)textField).inputType == ExerciseInputTypeDragAndDrop ||
        ((ExerciseTextField*)textField).inputType == ExerciseInputTypeScrambledLetters) {
        
        [textField resignFirstResponder];
        
        [_feeder scheduleNextBatchWhenReady];
    }
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {

    [(ExerciseTextField*)textField check];
    [(ExerciseTextField*)textField setSelected:NO];

    
    if ([self _currentTextFieldsAnswered]) {

        [textField resignFirstResponder];

        [_feeder scheduleNextBatchWhenReady];
    }
    else {
        
        [self _skipToNextTextField];
    }
    
    return NO;
}


#pragma mark - ...

- (IBAction) actionContentTap {
    
    [self.view endEditing:YES];
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
