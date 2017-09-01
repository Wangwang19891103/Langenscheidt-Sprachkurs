//
//  Exercise_Dialog_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseViewController.h"
#import "StackView.h"
#import "DialogFeeder.h"
#import "DialogLine.h"
#import "ExerciseTextView2.h"
#import "ExerciseTextField.h"
#import "ContentDataManager.h"
#import "DialogBubble.h"
#import "ExerciseCorrectionView.h"
#import "TextFieldCoordinator.h"


@interface Exercise_Dialog_ViewController2 : ExerciseViewController <DialogFeederDelegate, UITableViewDataSource, UITableViewDelegate, TextFieldCoordinatorDelegate> {
    
    DialogFeeder* _feeder;
    BOOL _viewFinishedLoading;
    NSArray* _dialogLines;
    UIView* _bottomMostItem;
//    BOOL _needsScrollToVisible;
    DialogBubble* _currentBubble;
    NSMutableDictionary* _speakerDict;
    UIScrollView* _scrollview;
    NSInteger _currentIndex;
    __block NSMutableArray* _cells;
    NSMutableArray* _textFieldCoordinators;  // parallel array to _cells (same indexes)
    
    dispatch_queue_t _backgroundQueue;
    
    BOOL _createOtherCellsNeeded;
    
    NSIndexPath* _currentBubbleIndexPath;  // latest inserted bubble
    
    BOOL _finishedInserting;
    BOOL _needsScrollToVisibleAfterInserting;
    
    int _previousTextFieldIndex;
    
    // correction view
    ExerciseCorrectionView* _correctionView;
    UITableViewCell* _correctionCell;
    NSIndexPath* _correctionIndexPath;
    
    UITableViewCell* _cellToBeInserted;
    
    BOOL _dialogFinished;
    
    UITableViewCell* _cellToBeDeleted;

    BOOL _finishedDeleting;
    
    BOOL _waitingForBatchDelay;
    
    BOOL _exerciseIsRunning;
    
    BOOL _currentTextFieldsAnswered;
    
    
    // score
    
    NSInteger _totalScore;
    NSInteger _totalMaxScore;
}

//@property (strong, nonatomic) IBOutlet StackView *contentStackView;

@property (nonatomic, strong) IBOutlet UITableView* tableView;


@end
