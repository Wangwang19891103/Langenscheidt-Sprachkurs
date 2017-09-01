//
//  PearlViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 07.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

//
//  CourseViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "PearlViewController.h"
#import "PearlMenuCell.h"
#import "ContentDataManager.h"
#import "TableViewHeader.h"
#import "PearlSorter.h"
#import "ExerciseNavigationController.h"
#import "SettingsManager.h"
#import "SubscriptionManager.h"


#import "LTracker.h"
#import "ScreenName.h"


#define PARALLAXING_HEADER_CAP          120

#define NUMBER_OF_LESSONS_LABEL_FORMAT      @"%ld/%ld Lerneinheiten"

#define DUMMY_NUMBER_OF_SOLVED_LESSONS      2
#define DUMMY_NUMBER_COURSE_POINTS      15


@implementation PearlViewController

@synthesize header;
@synthesize lesson;
@synthesize pointsLabel;
@synthesize numberOfLessonsLabel;
@synthesize lessonProgressBar;


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    _topButtonState = PearlViewControllerTopButtonStateNone;
    
    return self;
}


- (void) setLesson:(Lesson *)p_lesson {
    
    lesson = p_lesson;
    
    _pearls = [[ContentDataManager instance] pearlsForLesson:self.lesson];
    
    _pearls = [PearlSorter sortPearls:_pearls];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showExercisesForPearl"]) {
        
        ExerciseNavigationController* controller = (ExerciseNavigationController*)segue.destinationViewController;
        Pearl* pearl = ((PearlMenuCell*)sender).pearl;
        controller.exerciseCluster = [[ContentDataManager instance] firstClusterForPearl:pearl];
    }
}


#pragma mark - View, Layout, Constraints

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    GATrackingSetScreenName(@"Perlen-Menü");
    GATrackingSetTrackScreenViews(YES);
    LTrackerSetContentPath([ScreenName nameForLesson:self.lesson]);
    
    
    _viewLoaded = YES;
    
    
    
    [[SubscriptionManager instance] addObserver:self];
    
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"";
    
//    self.parallaxingHeaderCap = PARALLAXING_HEADER_CAP;
//    self.parallaxingRatio = 0.5;
//    self.parallaxingHeaderCap = 89 - 3;

    
    [self _setupImage];

//    [self update];
    
    self.titleLabel.text = self.lesson.title;
    
//    self.titleLabel.text = @"Kennenlernen und Smalltalk: Wiederholen";

    [self updateUI];

}


- (void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"PearlViewController - viewWillAppear (%@)", self);
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
//    NSLog(@"constraints: %@", self.view.constraints);
    
    self.parallaxingHeaderCap = 75.0;
    self.parallaxingRatio = 0.5;

    
    [self _updateSubscriptionStatus];
}




- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if (!self.tableView.tableHeaderView) {
        
        self.tableView.tableHeaderView = self.header;
    }
    
}



#pragma mark - Update UI

- (void) updateUI {

    if (!_viewLoaded) return;
    
    // --------------
    
    // needs to force on main queue, because it gets called from background threads (subscription manager)
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self _updateCompletionStatus];
        
        [self _updateTopButtonState];
        
        [self _updateTopButtonTitle];
        
        [self _updateScore];
        
        [self _updateCells];
    });
}


- (void) _updateCells {
    
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
    
    for (int i = 0; i < numberOfRows; ++i) {
        
        PearlMenuCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [cell updateProgress];
    }
}


- (void) _updateCompletionStatus {
    
    _completionStatus = [[UserProgressManager instance] completionStatusForLesson:self.lesson];
    
}


- (void) _updateTopButtonState {
    
    ContentManagerContentAvailabilityStatus availabilityStatus = [[ContentManager instance] contentAvailabilityStatusForLesson:self.lesson];
    
    if (availabilityStatus != ContentManagerContentAvailabilityStatusAvailable) {
        
        switch (availabilityStatus) {
            
            default:
            case ContentManagerContentAvailabilityStatusNoSubscription:
                _topButtonState = PearlViewControllerTopButtonStateUnlock;
                break;

            case ContentManagerContentAvailabilityStatusNotInstalled:
                _topButtonState = PearlViewControllerTopButtonStateDownload;
                break;
        }
    }
    else {
        
        switch (_completionStatus) {
                
            case UserProgressLessonCompletionStatusNew:
            default:
                _topButtonState = PearlViewControllerTopButtonStateStart;
                break;
                
            case UserProgressLessonCompletionStatusStarted:
                _topButtonState = PearlViewControllerTopButtonStateContinue;
                break;
                
            case UserProgressLessonCompletionStatusCompleted:
                _topButtonState = PearlViewControllerTopButtonStateRestart;
                break;
        }
    }
}


- (void) _updateTopButtonTitle {
    
    NSString* topButtonTitle = nil;
    
    switch (_topButtonState) {
            
        case PearlViewControllerTopButtonStateNone:
        default:
            topButtonTitle = @"";
            break;
            
        case PearlViewControllerTopButtonStateStart:
            topButtonTitle = @"STARTEN";
            break;
            
        case PearlViewControllerTopButtonStateContinue:
            topButtonTitle = @"FORTSETZEN";
            break;
            
        case PearlViewControllerTopButtonStateRestart:
            topButtonTitle = @"WIEDERHOLEN";
            break;
            
        case PearlViewControllerTopButtonStateUnlock:
            topButtonTitle = @"FREISCHALTEN";
            break;
            
        case PearlViewControllerTopButtonStateDownload:
            topButtonTitle = @"HERUNTERLADEN";
            break;
    }
    
    
    [self.topButton setTitle:topButtonTitle forState:UIControlStateNormal];
}


- (void) _setupImage {
    
    NSString* photoFile = self.lesson.imageFile;
    photoFile = [photoFile stringByDeletingPathExtension];
    photoFile = [[photoFile stringByAppendingString:@""] stringByAppendingPathExtension:@"jpg"];
    NSString* photosFolder = [[NSBundle mainBundle] pathForResource:@"Menu Photos" ofType:nil];
    NSString* fullPath = [photosFolder stringByAppendingPathComponent:photoFile];
    UIImage* image = [UIImage imageWithContentsOfFile:fullPath];

    self.imageView.image = image;
}




#pragma mark - Update Subscription Status

- (void) _updateSubscriptionStatus {
    
    NSLog(@"PearlViewController: updateSubscriptionStatus");
    
    [[SubscriptionManager instance] requestUpdateHasActiveSubscriptionForceValidation:NO];
}




#pragma mark - Top Button

- (IBAction) actionTopButton {
    
    switch (_topButtonState) {

        case PearlViewControllerTopButtonStateNone:
        default:
            break;

        case PearlViewControllerTopButtonStateStart:
        case PearlViewControllerTopButtonStateContinue:
            [self _startOrContinueLesson];
            break;
            
        case PearlViewControllerTopButtonStateRestart:
            [self _resetAndRestartLesson];
            break;
            
        case PearlViewControllerTopButtonStateDownload:
            [self _downloadContent];
            break;
            
        case PearlViewControllerTopButtonStateUnlock:
            [self _unlockContent];
            
    }
    
}


- (void) _startOrContinueLesson {
    
    ExerciseCluster* nextIncompleteExerciseCluster = [[UserProgressManager instance] nextIncompleteExerciseClusterForLesson222:self.lesson];
    
    [self pushExerciseNavigationControllerForExerciseCluster:nextIncompleteExerciseCluster withIntroScreen:YES];
}


- (void) _resetAndRestartLesson {
    
    [[UserProgressManager instance] startNextRunForLesson:self.lesson];
    
    [self _startOrContinueLesson];
}



#pragma mark - Table View

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _pearls.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PearlMenuCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    Pearl* pearl = _pearls[indexPath.row];
    
    cell.pearl = pearl;
    cell.position = ({
    
        PearlMenuCellPosition position;
        
        if (indexPath.row == 0) {
            
            position = PearlMenuCellPositionFirst;
        }
        else if (indexPath.row == _pearls.count - 1) {
            
            position = PearlMenuCellPositionLast;
        }
        else {
            
            position = PearlMenuCellPositionMiddle;
        }
            
        position;
    });
    
    [cell updateView];
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    if (_topButtonState == PearlViewControllerTopButtonStateDownload) {
        
        [self _downloadContent];
    }
    else if (_topButtonState == PearlViewControllerTopButtonStateUnlock) {
        
        [self _unlockContent];
    }
    else {
        
        Pearl* pearl = _pearls[indexPath.row];
        
        ExerciseCluster* exerciseCluster = [[UserProgressManager instance] nextIncompleteExerciseClusterForPearlInsideSamePearl:pearl];
        
        [self pushExerciseNavigationControllerForExerciseCluster:exerciseCluster withIntroScreen:NO];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Score

- (void) _updateScore {
    
    NSInteger score = [[UserProgressManager instance] scoreForLesson:self.lesson];
    NSInteger solvedPearls = [[UserProgressManager instance] numberOfSolvedPearlsForLesson:self.lesson];

    self.pointsLabel.text = [NSString stringWithFormat:@"%ld", score];
    
    CGFloat lessonProgressPercentage = (solvedPearls / (CGFloat)_pearls.count);
    self.lessonProgressBar.percentage = lessonProgressPercentage;
    
    self.numberOfLessonsLabel.text = [NSString stringWithFormat:NUMBER_OF_LESSONS_LABEL_FORMAT, solvedPearls, _pearls.count];

}



#pragma mark - Open ExerciseNavigationController

- (void) pushExerciseNavigationControllerForExerciseCluster:(ExerciseCluster*) exerciseCluster withIntroScreen:(BOOL) withIntroScreen {
    
    ExerciseNavigationController* navigationController = [[UIStoryboard storyboardWithName:@"exercises" bundle:[NSBundle mainBundle]]    instantiateViewControllerWithIdentifier:@"Navigation Controller"];
    navigationController.exerciseCluster = exerciseCluster;
    
    [navigationController openInNavigationController:self.navigationController withIntroScreen:withIntroScreen];
}





#pragma mark - Download Content

- (void) _downloadContent {
    
    [[ContentManager instance] addObserver:self];
    
    [[ContentManager instance] installContentForLesson:self.lesson parentViewController:self];
}



#pragma mark - Unlock Content

- (void) _unlockContent {
    
    [[ContentManager instance] addObserver:self];
    
    [[ContentManager instance] openShopPopupWithParentViewController:self];
}



#pragma mark - ContentManagerObserver

- (void) contentManagerFinishedInstallingContentForLesson:(Lesson *)lesson {
    
//    [[ContentManager instance] removeObserver:self];  // this would cause "was mutated while being enumerated." exception
    
    [self updateUI];
}



#pragma mark - SubscriptionManagerObserver

//- (void) subscriptionManagerDidUpdateSubscriptionStatus {
//    
//    [self updateUI];
//}


- (void) subscriptionManagerDidUpdateSubscriptionStatusValidating:(BOOL)validating {
    
    [self updateUI];
}




#pragma mark - Dealloc

- (void) dealloc {
    
    [[ContentManager instance] removeObserver:self];
    
    [[SubscriptionManager instance] removeObserver:self];
}

@end
