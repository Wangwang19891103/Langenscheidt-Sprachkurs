//
//  Exercise_Dialog_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Exercise_Dialog_ViewController2.h"
#import "NSMutableAttributedString+HTML.h"
#import "NSString+Clean.h"
#import "CGExtensions.h"
#import "UIScrollView+NoScroll.h"
#import "DialogBubbleCell.h"
//#import "DialogNarratorBubble.h"


/*
 * - whenever an audio part begins to play, the bubble will be inserted at the same time (with animation)
 * - if a bubble contains an exercise, the keyboard will only appear once the audio finished playing (and animation finished, but should never be the case before the audio finished)
 *
 * + after entering for a textfield and hitting return/done -> the next textfield becomes first responder. if theres no next textfield -> the dialog continues after a short delay
 * + after all textfields have been answered -> short delay before next audio/bubble
 * + place fade view correctly
 * + upon dismissing the keyboard, the bottom cell should be scrolled to visible
 *
 * + Special cases:
 * -- line has no speaker (-> is narrator) and can or can not have an audio range
 * -> need "narrator bubbles" with audio and without
 * -- narrator bubbles with audio can be inserted like normal bubbles (flow) just without a speaker label and arrow
 * -- narrator bubbles without audio - idea 1: inserted like bubbles with audio. the following bubble wud be inserted right afterwards since there is no time delay due to audio
 * -- idea 2: has special insertion/layout
 * -- problem: user needs time to read the narrator bubble -> there needs to be a default delay for these then
 *
 * + popupfile can be in second line, not always in first
 *
 * + audio shud begin only after the bubble has finished displaying (tableview reloading, event will/did display cell)
 *
 */


//#define DIALOG_DEBUG
//#define TEST_BUBBLE_NUMBER      8


#define SCROLL_TO_VISIBLE_INSETS                UIEdgeInsetsMake(40, 20, 40, 20)

#define BOTTOM_PLACEHOLDER_HEIGHT               60

// delays

#define INSERT_ANIMATION_DELAY                  0.3
#define DELAY_BEFORE_FIRST_BUBBLE               0.5
#define DELAY_BEFORE_NEXT_BUBBLE                1.0
#define DELAY_BEFORE_CORRECTIONVIEW             0.5
#define DELAY_BEFORE_NEXT_BUTTON_FOR_CORRECTIONVIEW     1.5
#define DELAY_BEFORE_NEXT_BUBBLE_AFTER_CORRECTIONVIEW       0.5

#define CORRECTION_CELL_MARGINS                 UIEdgeInsetsMake(8,20,100,20)




@implementation Exercise_Dialog_ViewController2



- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    self.layoutMode = FullscreenWithAdjust;
    self.canBeChecked = NO;
    self.mustBeStarted = YES;
    self.hidesBottomButtonInitially = YES;
    _backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    _currentIndex = -1;
    _cells = [NSMutableArray array];
    _textFieldCoordinators = [NSMutableArray array];
    _createOtherCellsNeeded = YES;
    _totalScore = 0;
    _totalMaxScore = 0;
    _currentTextFieldsAnswered = YES;

    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    _dialogLines = self.exerciseDict[@"dialogLines"];
    
    
    _viewFinishedLoading = YES;

    
    [self.tableView registerClass:[DialogBubbleCell class] forCellReuseIdentifier:@"bubbleCell"];
    self.tableView.estimatedRowHeight = 160;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self _createSpeakerDictioanry];

    
    [self _createFirstCell];
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillHideNotification object:nil];
    
//    [self.contentStackView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [self.prototypeTextContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
#ifdef TEST_BUBBLE_NUMBER

    [self _insertNextItemWithIndex:TEST_BUBBLE_NUMBER];
    
#else

    
#endif
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    _scrollview = [self _findParentScrollview];
    _scrollview = self.tableView;

//    [self.exerciseNavigationController setBottomButtonHidden:YES animated:NO];

}



#pragma mark - Start/Stop Exercise

- (void) start {

    if (_exerciseIsRunning) return;
    

    _exerciseIsRunning = YES;
    
    Exercise* exercise = self.exerciseDict[@"exerciseObject"];
//    Course* course = [[ContentDataManager instance] courseForExerciseCluster:exercise.cluster];
    Lesson* lesson = [[ContentDataManager instance] lessonForExerciseCluster:exercise.cluster];
    
    _feeder = [[DialogFeeder alloc] initWithDialogLines:_dialogLines withLesson:lesson];
    _feeder.delegate = self;

    [self _scheduleFirstBatchWhenReady];
}


- (void) stop {
    
    [super stop];
    
    _exerciseIsRunning = NO;
    
    [self _stopDialogFeeder];
}



#pragma mark - Stop Exercise

- (void) _stopDialogFeeder {
    
    [_feeder stop];
    _feeder.delegate = nil;
    _feeder = nil;
}




#pragma mark - Create Cells

- (void) _createFirstCell {
    
    NSDictionary* dialogLine = _dialogLines[0];
    
    // create first cell synchronously
    
    [self _createItemForDialogLine:dialogLine];
}


- (void) _createOtherCellsIfNeeded {
    
    if (!_createOtherCellsNeeded) return;
    
    
    _createOtherCellsNeeded = NO;
    
    // create other cells asynchronously on background queue

    dispatch_async(_backgroundQueue, ^{

        for (int i = 1; i < _dialogLines.count; ++i) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{

                NSDictionary* dialogLine = _dialogLines[i];

                [self _createItemForDialogLine:dialogLine];

            });
            
            
        }
        
        ;
    });
}



#pragma mark - Speaker Dictionary

- (void) _createSpeakerDictioanry {

    _speakerDict = [NSMutableDictionary dictionary];
    int speakerCount = 0;
    
    for (NSDictionary* dialogLine in _dialogLines) {
        
        NSString* speaker = dialogLine[@"speaker"];
        speaker = [speaker cleanString];
        
        if (!speaker || speaker.length == 0) {
            
            _speakerDict[@"_narrator"] = @{
                                      @"color" : @(kDialogBubbleNarratorColor),
                                      @"side" : @(0)
                                      };
        }
        
        if (!_speakerDict[speaker]) {  // new speaker found
            
            if (speaker.length == 0) continue;
            
            
            int side = speakerCount % 2;
            
            _speakerDict[speaker] = @{
                                      @"color" : @(speakerCount),
                                      @"side" : @(side)
                                      };
            
            ++speakerCount;
        }
    }
}



#pragma mark - Instruction

- (NSString*) instruction {
    
    return @"Höre den Dialog und ergänze";
}



#pragma mark - View, Layout, Constraints

-  (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
//    [self _scrollToVisibleIfNeeded];
}



#pragma mark - Schedule next batch

- (void) _scheduleFirstBatchWhenReady {
    
    [self _scheduleNextBatchWhenReadyWithDelay:DELAY_BEFORE_FIRST_BUBBLE];
}


- (void) _scheduleNextBatchWhenReady {
    
    [self _scheduleNextBatchWhenReadyWithDelay:DELAY_BEFORE_NEXT_BUBBLE];
}


- (void) _scheduleNextBatchWhenReadyWithDelay:(NSTimeInterval) delay {

    // resets
    
    _previousTextFieldIndex = -1;
    
    _waitingForBatchDelay = YES;
    
//    [_feeder performSelector:@selector(scheduleNextBatchWhenReady) withObject:nil afterDelay:delay];
    
    [self performSelector:@selector(_fireScheduledBatchRequest) withObject:nil afterDelay:delay];
    
//    [_feeder scheduleNextBatchWhenReady];
}


- (void) _fireScheduledBatchRequest {
    
    _waitingForBatchDelay = NO;
    
    [_feeder scheduleNextBatchWhenReady];
}



#pragma mark - Handle DialogFeeder Events

- (void) _handleDialogFeederWillPlayNextPartWithIndex:(NSInteger) index {
    
    [self _insertNextItemWithIndex:index];
    
    [self _createOtherCellsIfNeeded];  // will create other cells AFTER the first bubble has been added AND the audio has started, MEANS there is now time on the main thread to create cells
}


- (void) _handleDialogFeederDidEndPlayingPartWithIndex:(NSInteger) index {
    
    
}


- (void) _handleDialogFeederDidEndPlayingBatch {

    TextFieldCoordinator* coordinator = _textFieldCoordinators[_currentIndex];

    if (coordinator.textFields.count == 0) {  // bubble / coordinator has no gaps
        
        [self _finishDialogIfReady];
    }
    else {

        [coordinator setFirstTextfieldActive];
        [coordinator openFirstTextField];
    }
}


- (void) _handleDialogFeederWillPlayArtificialDelayWithIndex:(NSInteger) index {
    
    [self _insertNextItemWithIndex:index];

    [self _createOtherCellsIfNeeded];
}


- (void) _handleDialogFeederDidEndPlayingArtificialDelayWithIndex:(NSInteger) index {
    
    _currentTextFieldsAnswered = YES;  // to tell feeder that were ready for next batch
    
    [self _scheduleNextBatchWhenReady];
}





#pragma mark - TableView Delegate & DataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    return _currentIndex + 1 + 1 + ((_correctionIndexPath != nil) ? 1 : 0);  // +1 for 0-based index, +1 for placeholder cell, + 1 for correction cell (if available)

    
    // either placeholder or correction cell
    
    return _currentIndex + 1 + 1;  // +1 for 0-based index, +1 for placeholder cell

}


- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    BOOL correctionCellExists = (_correctionIndexPath != nil);
    NSInteger correctionCellIndex = correctionCellExists ? (_currentIndex + 1) : -1;
    NSInteger bottomPlaceholderIndex = correctionCellExists ? (_currentIndex + 1) : (_currentIndex + 1);
    
    // case correction cell
    
    if (correctionCellExists && indexPath.row == correctionCellIndex) {
        
        CGFloat height = [self _correctionCellHeight];
        
        NSLog(@"correction cell height: %f", height);
        
        return height;
    }
    
    // case placeholder cell
    
    else if (indexPath.row == bottomPlaceholderIndex) {
        
        return BOTTOM_PLACEHOLDER_HEIGHT;
    }
    else {
    
        DialogBubbleCell* cell = _cells[indexPath.row];
        UIView* innerView = cell.innerView;
        
        CGFloat cellHeight = innerView.frame.size.height + [DialogBubbleCell margins].top + [DialogBubbleCell margins].bottom;
        cellHeight = ceil(cellHeight);
        
        NSLog(@"CELL HEIGHT %f (bubble: %@)", cellHeight, innerView);
        
        return cellHeight;
    }
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BOOL correctionCellExists = (_correctionIndexPath != nil);
    NSInteger correctionCellIndex = correctionCellExists ? (_currentIndex + 1) : -1;
    NSInteger bottomPlaceholderIndex = correctionCellExists ? (_currentIndex + 1) : (_currentIndex + 1);
    
    // case correction cell
    
    if (correctionCellExists && indexPath.row == correctionCellIndex) {
        
        return _correctionCell;
    }
    
    // case placeholder cell
    
    else if (indexPath.row == bottomPlaceholderIndex) {
        
        UITableViewCell* cell = [[UITableViewCell alloc] init];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else {
        
        DialogBubbleCell* cell = _cells[indexPath.row];
        return cell;
    }
}


- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_cellToBeInserted == cell && _correctionIndexPath && indexPath.row == _correctionIndexPath.row) {
        
        [self _scrollCorrectionCellToVisible];
        
        _needsScrollToVisibleAfterInserting = NO;
        _cellToBeInserted = nil;
        
        cell.alpha = 0.0;
        
        
        [UIView animateWithDuration:INSERT_ANIMATION_DELAY delay:DELAY_BEFORE_CORRECTIONVIEW options:0 animations:^{
            
            cell.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            _finishedInserting = YES;
            
        }];
    }
    
    else if (_cellToBeInserted == cell && _currentBubbleIndexPath && indexPath.row == _currentBubbleIndexPath.row) {

        NSLog(@"displaying bubble cell: %@", cell);
        
        [self _scrollBottomToVisible];

        
        _needsScrollToVisibleAfterInserting = NO;
        _cellToBeInserted = nil;
        
        cell.alpha = 0.0;
        
        
        [UIView animateWithDuration:INSERT_ANIMATION_DELAY delay:0 options:0 animations:^{
            
            cell.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
            _finishedInserting = YES;
            
        }];
    }
    
}





#pragma mark - Dialog Items

- (void) _insertNextItemWithIndex:(NSInteger) index {
    
    _currentIndex = index;
    _currentTextFieldsAnswered = NO;
    
    
//    NSDictionary* dialogLine = _dialogLines[index];
//    
//    [self _createItemForDialogLine:dialogLine];
    
//    StackViewSubviewOrientation subviewOrientation = (bubble.side == 0) ? StackViewSubviewOrientationLeft : StackViewSubviewOrientationRight;

    DialogBubbleCell* cell = _cells[index];
    
    if ([cell.innerView isKindOfClass:[DialogBubble class]]) {
        
        _currentBubble = (DialogBubble*)cell.innerView;
    }
    
    _cellToBeInserted = cell;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    _currentBubbleIndexPath = indexPath;
    _needsScrollToVisibleAfterInserting = YES;
    _finishedInserting = NO;
    
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView endUpdates];
//
    
    
    [self.tableView reloadData];

    [self _scrollBottomToVisible];

//    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
//    [self _scheduleScrollToVisibleOnView:bubble];
    
}


- (void) _createItemForDialogLine:(NSDictionary*) dialogLine {

    NSString* speaker = [dialogLine[@"speaker"] cleanString];
    
    BOOL isNarrator = (!speaker || speaker.length == 0);
    
    if (isNarrator) {
        
        speaker = @"_narrator";
    }
    
//    // case narrator bubble
//    
//    if (speaker.length == 0) {
//        
//        DialogNarratorBubble* bubble = [[DialogNarratorBubble alloc] init];
//        bubble.textLang1 = dialogLine[@"textLang1"];
//        bubble.textLang2 = dialogLine[@"textLang2"];
//        
//        [bubble createView];
//        
//        DialogBubbleCell* cell = [[DialogBubbleCell alloc] init];
//        cell.backgroundColor = [UIColor clearColor];
//        cell.innerView = bubble;
//        
//        [_cells addObject:cell];
//    }
//    
//    // case normal bubble
    
//    else {
    
        NSDictionary* speakerDict = _speakerDict[speaker];
        DialogBubbleColor color = [speakerDict[@"color"] integerValue];
        NSInteger side = [speakerDict[@"side"] integerValue];
        
        DialogBubble* bubble = [[DialogBubble alloc] init];
        bubble.speaker = dialogLine[@"speaker"];
        bubble.textLang1 = dialogLine[@"textLang1"];
        bubble.textLang2 = dialogLine[@"textLang2"];
        bubble.color = color;
        bubble.side = side;
        //    bubble.rasterize = YES;
    bubble.isNarratorBubble = isNarrator;
        
        [bubble createView];
        
        DialogBubbleCell* cell = [[DialogBubbleCell alloc] init];
        cell.backgroundColor = [UIColor clearColor];
        //    cell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        cell.innerView = bubble;
        
        //    [cell setNeedsLayout];
        //    [cell layoutIfNeeded];
        
        [_cells addObject:cell];
        
        [self _assignInputTypesForTextFields:bubble.textFields withDialogLine:dialogLine];
//        [bubble.textFields makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
        
        TextFieldCoordinator* coordinator = [[TextFieldCoordinator alloc] init];
        [coordinator addTextFields:bubble.textFields];
        coordinator.delegate = self;
        
        [_textFieldCoordinators addObject:coordinator];
        
        //    _currentBubble = bubble;
//    }
    

}


//- (StackView*) _createContainerView {
//    
//    StackView* view = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.prototypeTextContainerView]];
//    view.spacing = self.prototypeTextContainerView.spacing;
//    
//    return view;
//}


//- (ExerciseTextView2*) _createTextView {
//    
//    ExerciseTextView2* textView = [[ExerciseTextView2 alloc] init];
//    textView.inputType = ExerciseInputTypeStandard;
//    textView.layoutMargins = UIEdgeInsetsZero;
//    
//    if (textView.inputType == ExerciseInputTypeDragAndDrop) {
//        
//        textView.generateSharedSolutions = YES;
//    }
//    
//    return textView;
//}




//- (UITextView*) _createLanguage2TextView {
//    
//    UITextView* textView = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.prototypeLanguage2TextView]];
//    textView.textContainerInset = self.prototypeLanguage2TextView.textContainerInset;
//    textView.textContainer.lineFragmentPadding = self.prototypeLanguage2TextView.textContainer.lineFragmentPadding;
//    textView.font = self.prototypeLanguage2TextView.font;
//    textView.selectable = NO;
//    
//    return textView;
//}



#pragma mark - Textfields

- (BOOL) _textFieldIsFirstResponder {
    
    return [self _currentTextFieldFirstResponder] != nil;
}


- (ExerciseTextField*) _currentTextFieldFirstResponder {
    
    for (ExerciseTextField* textField in _currentBubble.textFields) {
        
        if ([textField isFirstResponder]) {
            
            return textField;
        }
    }
    
    return nil;
}


- (void) _skipToNextTextField {
    
    // case bubble has no textfields
    
    if (_currentBubble.textFields.count == 0) {
        
        
    }
    
    
    // case bubble has textfields
    
    else {
        
        if (_previousTextFieldIndex >= 0) {
            
            ExerciseTextField* textField = _currentBubble.textFields[_previousTextFieldIndex];
            textField.userInteractionEnabled = NO;
        }
        
        
        uint nextTextFieldIndex = _previousTextFieldIndex + 1;
        
        //    // find active responder if available
        //
        //    for (uint i = 0; i < _currentBubble.textFields.count; ++i) {
        //
        //        UITextField* textField = _currentBubble.textFields[i];
        //
        //        if ([textField isFirstResponder]) {
        //
        //            NSLog(@"current responder index: %d", i);
        //
        //            nextTextFieldIndex = i + 1;
        //            break;
        //        }
        //    }
        
        if (nextTextFieldIndex < _currentBubble.textFields.count) {
            
            // make next textfield first responder
            
            NSLog(@"Skipping to next textfield with index %d", nextTextFieldIndex);
            
            ExerciseTextField* textField = _currentBubble.textFields[nextTextFieldIndex];
            textField.userInteractionEnabled = YES;
            [textField becomeFirstResponder];
            
            ++_previousTextFieldIndex;
        }
        else {
            
            // resign first responder
            
            NSLog(@"Resigning first responder");
            
            [self.view endEditing:YES];
            
            ExerciseTextField* textField = _currentBubble.textFields[_previousTextFieldIndex];
            textField.userInteractionEnabled = NO;
            
            [self check];
        }
        
    }
    
}


//- (BOOL) _currentTextFieldsAnswered {
//    
//    BOOL allAnswered = YES;
//    
//    //    NSLog(@"count: %ld", _currentTextView.textFields.count);
//    
//    for (ExerciseTextField* textField in _currentBubble.textFields) {
//        
//        //        NSLog(@"solutionState: %ld", textField.solutionState);
//        
//        if (textField.solutionState == ExerciseControlSolutionStateFresh) {
//            
//            allAnswered = NO;
//            break;
//        }
//    }
//    
//    return allAnswered;
//}


- (void) _assignInputTypesForTextFields:(NSArray*) textFields withDialogLine:(NSDictionary*) dialogLine {
    
    NSArray* IDs = [dialogLine[@"vocabularyIDs"] componentsSeparatedByString:@","];
    
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
        
        int vocabularyID = -1;
        BOOL hasVocabularyID = NO;
        
        if (i < IDs.count) {
            
            NSString* IDString = IDs[i];
            
            
            if (IDString.length > 0) {
                
                vocabularyID = (int)[IDString integerValue];
                
                hasVocabularyID = (vocabularyID > 0);
            }
        }
        
        NSArray* possibleTypes = (hasVocabularyID) ? possibleTypesWithDND : possibleTypesWithoutDND;

        ExerciseTextField* textField = textFields[i];

        __block uint typeIndex;
        __block ExerciseInputType type;
        
        void(^roll)() = ^() {
            
            typeIndex = arc4random() % possibleTypes.count;
            type = [possibleTypes[typeIndex] integerValue];
        };
        
        roll();
        
        if (textField.disableStandard) {
            
            while (type == ExerciseInputTypeStandard) {
                
                roll();
            }
            
        }
        
        
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
            
//            [solutions insertObject:vocabulary.textLang1 atIndex:0];
            [solutions insertObject:textField.solutionStrings.firstObject atIndex:0];
        }
        else {
            
            [solutions addObject:vocabulary.textLang1];
        }
    }
    
    textField.solutionStrings = solutions;
}





#pragma mark - Scroll to visible

- (void) _scrollCurrentBubbleToVisible {

    NSLog(@"inserted indexpath: %@", _currentBubbleIndexPath);
    
    [self.tableView scrollToRowAtIndexPath:_currentBubbleIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


- (void) _scrollBottomToVisible {
    
    NSIndexPath* lastIndexPath = [NSIndexPath indexPathForRow:_currentIndex + 1 inSection:0];
    
    @try {

        NSInteger nuberofrows = [self tableView:self.tableView numberOfRowsInSection:0];

        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        
    } @catch (NSException *exception) {
        
        NSLog(@"exception: %@", exception);
    } @finally {
        
    }
    
}


- (void) _scrollCorrectionCellToVisible {
    
    [self.tableView scrollToRowAtIndexPath:_correctionIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


//- (void) _scheduleScrollToVisibleOnView:(UIView*) view {
//    
//    _bottomMostItem = view;
//    _needsScrollToVisible = YES;
//}


//- (void) _scrollToVisibleIfNeeded {
//    
//    if (!_needsScrollToVisible) return;
//    
//    _needsScrollToVisible = NO;
//    
//    [self.contentStackView setNeedsLayout];  // force layout in order to receive frame of bottom most item
//    [self.contentStackView layoutIfNeeded];
//    [_scrollview setNeedsLayout];        // also force scrollview layout or it wont have the proper content size from autolayout
//    [_scrollview layoutIfNeeded];
//    
//    [self _scrollViewToVisible:_bottomMostItem];
//}


//- (void) _scrollViewToVisible:(UIView*) theView {
//    
//    CGRect rect = [_scrollview convertRect:theView.bounds fromView:theView];
//    rect = CGRectOutset(rect, SCROLL_TO_VISIBLE_INSETS);
//    
//    NSLog(@"scrolling rect to visible: %@", NSStringFromCGRect(rect));
//    
//    [_scrollview scrollRectToVisible2:rect animated:YES];
//}
//
//
//- (UIScrollView*) _findParentScrollview {
//    
//    UIView* superview = self.view.superview;
//    
//    while (superview && ![superview isKindOfClass:[UIScrollView class]]) {
//        
//        superview = superview.superview;
//    }
//    
//    return (UIScrollView*)superview;
//}




#pragma mark - DialogFeederDelegate

- (void) dialogFeeder:(DialogFeeder *)feeder willPlayNextPartWithIndex:(NSInteger)index {
    
    [self _handleDialogFeederWillPlayNextPartWithIndex:index];
    
}


- (void) dialogFeeder:(DialogFeeder *)feeder didEndPlayingPartWithIndex:(NSInteger)index {
    
    [self _handleDialogFeederDidEndPlayingPartWithIndex:index];
}


- (void) dialogFeederDidEndPlayingBatch:(DialogFeeder *)feeder {
    
    [self _handleDialogFeederDidEndPlayingBatch];
}


- (BOOL) dialogFeederReadyForNextBatch:(DialogFeeder *)feeder {  // is this controller ready for next batch?
    
#ifdef DIALOG_DEBUG

    return YES;
    
#else

    return _viewFinishedLoading && _currentTextFieldsAnswered && !_waitingForBatchDelay;

#endif
    
}


- (void) dialogFeederFinishedAllBatches:(DialogFeeder *)feeder {
    
    NSLog(@"FINISHED");
    
    _dialogFinished = YES;
    
    [self _finishDialogIfReady];
    
//    [self setScore:_totalScore ofMaxScore:_totalMaxScore];
//    
//    [self stop];
//    
//    [self showBottomButton];
}


- (void) dialogFeeder:(DialogFeeder *)feeder willPlayArtificialDelayWithIndex:(NSInteger)index {
    
    [self _handleDialogFeederWillPlayArtificialDelayWithIndex:index];
}


- (void) dialogFeeder:(DialogFeeder *)feeder didEndPlayingArtificialDelayWithIndex:(NSInteger)index {
    
    [self _handleDialogFeederDidEndPlayingArtificialDelayWithIndex:index];
}



//#pragma  mark - UITextFieldDelegate
//
//- (void) textFieldDidBeginEditing:(UITextField *)textField {
//    
//    NSLog(@"textFieldDidBeginEditing");
//    
//    //    [self scrollTextFieldToVisible:(ExerciseTextField*)textField];
//    
//    [(ExerciseTextField*)textField setSelected:YES];
//    
//    [self _scrollCurrentBubbleToVisible];
//}
//
//
//- (void) textFieldDidEndEditing:(UITextField *)textField {
//    
//    NSLog(@"textFieldDidEndEditing");
//    
////    [(ExerciseTextField*)textField check];
//    [(ExerciseTextField*)textField setSelected:NO];
//    
////    if (((ExerciseTextField*)textField).inputType == ExerciseInputTypeDragAndDrop ||
////        ((ExerciseTextField*)textField).inputType == ExerciseInputTypeScrambledLetters) {
////        
////        [textField resignFirstResponder];
////        
////        [_feeder scheduleNextBatchWhenReady];
////    }
//    
//    if (_exerciseIsRunning) {
//    
//        [self _skipToNextTextField];
//    }
//    
//}
//
//
//- (BOOL) textFieldShouldReturn:(UITextField *)textField {
//    
//    NSLog(@"textFieldShouldReturn");
//    
//////    [(ExerciseTextField*)textField check];
////    [(ExerciseTextField*)textField setSelected:NO];
////    
////    
////    if ([self _currentTextFieldsAnswered]) {
////        
////        [textField resignFirstResponder];
////        
////        [_feeder scheduleNextBatchWhenReady];
////    }
////    else {
////        
////        [self _skipToNextTextField];
////    }
//
//    if (((ExerciseTextField*)textField).inputType == ExerciseInputTypeStandard) {
//
//        [textField resignFirstResponder];
//    }
//    
//    return NO;
//}




#pragma mark - TextFieldCoordinatorDelegate

- (void) textFieldCoordinatorTextFieldDidBeginEditing:(TextFieldCoordinator *)coordinator {
    
    [self _scrollCurrentBubbleToVisible];
}


- (void) textFieldCoordinatorLastTextFieldDidFinish:(TextFieldCoordinator *)coordinator {
    
    _currentTextFieldsAnswered = YES;
    
    [self check];
}


- (BOOL) textFieldCoordinatorShouldSetLastTextFieldInactive:(TextFieldCoordinator *)coordinator {
    
    return YES;
}


- (BOOL) textFieldCoordinatorShouldOpenKeyboard:(TextFieldCoordinator *)coordinator {
    
    BOOL presentingPopup = self.exerciseNavigationController.presentingPopup;
    
    return !presentingPopup;
}




#pragma mark - Keyboard

- (void) handleKeyboardDidChangeFrameVisible:(BOOL) visible {
    
    if (visible) {
    
        [self _scrollCurrentBubbleToVisible];
    }
    else {
        
        [self _scrollBottomToVisible];
    }
}



#pragma mark - Correction View Cell / Check

- (void) check {

    BOOL correct = [_currentBubble.textView check];
//    correct = YES;
    NSInteger score = _currentBubble.textView.scoreAfterCheck;
    NSInteger maxScore = _currentBubble.textView.maxScore;
    
    [self _increaseScore:score maxScore:maxScore];
    
    
    if (correct) {
        
        [self playCorrectSound];
        
        if (!_dialogFinished) {
        
            [self _scheduleNextBatchWhenReady];
        }
        else {

            [self _finishDialog];
        }
    }
    else {

        [self playWrongSound];
        
//        [self performSelector:@selector(_insertCorrectionView) withObject:nil afterDelay:DELAY_BEFORE_CORRECTIONVIEW];
        
        [self _insertCorrectionView];
    }
}


- (void) _insertCorrectionView {
    
    _correctionView = [[ExerciseCorrectionView alloc] init];
    _correctionView.strings = @[_currentBubble.textView.string];
    
    [_correctionView createView];
    
    _correctionIndexPath = [NSIndexPath indexPathForRow:_currentIndex + 1 inSection:0];
    
    _correctionCell = [self _createCorrectionCellWithView:_correctionView];

    [_correctionCell setNeedsLayout];
    [_correctionCell layoutIfNeeded];

    _cellToBeInserted = _correctionCell;
    
    _needsScrollToVisibleAfterInserting = YES;
    _finishedInserting = NO;

    [self.tableView reloadData];
    
    [self performSelector:@selector(_showNextButton) withObject:nil afterDelay:DELAY_BEFORE_NEXT_BUTTON_FOR_CORRECTIONVIEW];
}


- (void) _showNextButton {

    [self.exerciseNavigationController setBottomButtonHidden:NO animated:YES];
}


- (void) _hideNextButton {
    
    [self.exerciseNavigationController setBottomButtonHidden:YES animated:YES];
}


- (UITableViewCell*) _createCorrectionCellWithView:(ExerciseCorrectionView*) correctionView {
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 1000)];
    cell.backgroundColor = [UIColor clearColor];
    
    [cell.contentView addSubview:correctionView];
    
    UIEdgeInsets margins = CORRECTION_CELL_MARGINS;
    
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[correctionView]-(right)-|" options:0 metrics:@{@"left" : @(margins.left), @"right" : @(margins.right)} views:NSDictionaryOfVariableBindings(correctionView)]];
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[correctionView]" options:0 metrics:@{@"top" : @(margins.top)} views:NSDictionaryOfVariableBindings(correctionView)]];

    
    return cell;
}


- (CGFloat) _correctionCellHeight {

    UIEdgeInsets margins = CORRECTION_CELL_MARGINS;

    NSLog(@"correction view frame: %@", NSStringFromCGRect(_correctionView.frame));
    
    return _correctionView.frame.size.height + margins.top + margins.bottom;
}


- (void) _removeCorrectionView {

//    NSIndexPath* superDummy = [NSIndexPath indexPathForRow:_correctionIndexPath.row inSection:_correctionIndexPath.section];

    _correctionIndexPath = nil;

    
//    _correctionCell.alpha = 1.0;
//    
//    [UIView animateWithDuration:INSERT_ANIMATION_DELAY delay:0 options:0 animations:^{
//        
//        _correctionCell.alpha = 0.0;
//        
//    } completion:^(BOOL finished) {
//        
//        [self.tableView reloadData];
//        
//    }];

    
    if (_dialogFinished) {

        [self.tableView reloadData];
        
        [self _finishDialog];
    }
    else {
        
        [self _hideNextButton];
        
        [self _scheduleNextBatchWhenReadyWithDelay:DELAY_BEFORE_NEXT_BUBBLE_AFTER_CORRECTIONVIEW + INSERT_ANIMATION_DELAY];
    }
    

}




#pragma mark - Handle Next Button

- (BOOL) shouldHandleNextButton {
    
    if (_correctionIndexPath != nil) {
        
        return YES;
    }
    else {
        
        return NO;
    }
}


- (void) handleNextButton {
    
    if (_correctionIndexPath != nil) {
        
        [self _removeCorrectionView];
    }
}



#pragma mark - Handle Content Tap

- (BOOL) shouldHandleContentTap {
    
    return YES;
}


- (void) handleContentTap {
    
    
}




#pragma mark - Finish Dialog

- (void) _finishDialog {

    [self setScore:_totalScore ofMaxScore:_totalMaxScore];
    
    [self stop];
    
    [self showBottomButton];
}


- (void) _finishDialogIfReady {
    
    TextFieldCoordinator* currentCoordinator = _textFieldCoordinators[_currentIndex];
    
    BOOL currentBubbleHasNoTextfields = currentCoordinator.textFields.count == 0;
    
    if (_dialogFinished && currentBubbleHasNoTextfields) {
        
        [self _finishDialog];
    }
}



#pragma mark - Score

- (void) _increaseScore:(NSInteger) score maxScore:(NSInteger) maxScore {
    
    _totalScore += score;
    _totalMaxScore += maxScore;
}




#pragma mark - Dealloc

- (void) dealloc {
    
    [Exercise_Dialog_ViewController2 cancelPreviousPerformRequestsWithTarget:self];
}


@end
