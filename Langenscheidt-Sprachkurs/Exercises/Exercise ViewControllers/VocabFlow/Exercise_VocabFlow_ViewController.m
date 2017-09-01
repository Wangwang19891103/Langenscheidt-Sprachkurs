//
//  Exercise_VocabFlow_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Exercise_VocabFlow_ViewController.h"
#import "VocabFlowPageViewController.h"
#import "VocabFlowGrammarPageViewController.h"
#import "VocabFlowVocabularyPageViewController.h"



#define SCORE_PER_PAGE        1



@implementation Exercise_VocabFlow_ViewController

@synthesize pageControllerContainer;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    self.layoutMode = FullscreenWithoutAdjust;
    self.canBeChecked = NO;
    self.hidesBottomButtonInitially = YES;
    
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self determineMode];
    
    [self createView];
    
}


- (void) determineMode {
    
    NSMutableArray* lines = [NSMutableArray arrayWithArray:self.exerciseDict[@"lines"]];
    NSDictionary* firstLine = lines[0];
    
    if ([firstLine[@"field1"] isEqualToString:@"vocabularies"]) {
        
        _mode = Vocabularies;
    }
    else {
        
        _mode = Grammar;
    }
}


- (void) createView {
    
    NSString* toptext = self.exerciseDict[@"topText"];
    
//    if (toptext) {
//        
//        self.topTextLabel.text = self.exerciseDict[@"topText"];
//    }
//    else {
//        
//        [self.topTextContainer removeFromSuperview];
//        
//        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pageControllerContainer]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(pageControllerContainer)]];
//    }

    
    // page view controller
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    
    [self addChildViewController:_pageViewController];
    
    [self.pageControllerContainer addSubview:_pageViewController.view];
    UIView* pageControllerView = _pageViewController.view;
    pageControllerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.pageControllerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[pageControllerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(pageControllerView)]];
    [self.pageControllerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pageControllerView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(pageControllerView)]];
    
    
    [self _createPages];
    
    [_pageViewController setViewControllers:@[_pages[0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    
    // page control
    
    self.pageControl.numberOfPages = _pages.count;
    [self.pageControl createView];
    [self _updatePageControl];
    
}


- (void) _createPages {
    
    NSMutableArray* lines = [NSMutableArray arrayWithArray:self.exerciseDict[@"lines"]];
    NSMutableArray* pageControllers = [NSMutableArray array];
    
    if (_mode == Vocabularies) {
    
        [lines removeObjectAtIndex:0];
    }

    uint pageIndex = 0;
    
    for (NSDictionary* lineDict in lines) {

        VocabFlowPageViewController* pageController = nil;
        
        if (self.mode == Grammar) {
            
            pageController = [self _createGrammarPageViewControllerWithDictionary:lineDict];
        }
        else {
            
            pageController = [self _createVocabularyPageViewControllerWithDictionary:lineDict];
        }

        pageController.pageIndex = pageIndex++;
        
        [pageControllers addObject:pageController];
    }


    _pages = pageControllers;
}


- (void) _updatePageControl {
    
    self.pageControl.currentPageIndex = _currentPage;
}


- (VocabFlowPageViewController*) _createGrammarPageViewControllerWithDictionary:(NSDictionary*) dict {
 
    VocabFlowGrammarPageViewController* pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"VocabFlowGrammarPage"];
    pageController.dict = dict;
    
    return pageController;
}


- (VocabFlowPageViewController*) _createVocabularyPageViewControllerWithDictionary:(NSDictionary*) dict {
    
    VocabFlowVocabularyPageViewController* pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"VocabFlowVocabularyPage"];
    pageController.dict = dict;
    
    return pageController;
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
//    [self.exerciseNavigationController setBottomButtonHidden:YES animated:NO];
}


- (NSString*) instruction {

    if (_mode == Vocabularies) {
        
        return @"Höre die Vokabel an";
    }
    else return [super instruction];
}




#pragma mark - Update Popup Button

- (void) _updatePopupButtonWithFile:(NSString*) popupFile {
    
    [self.exerciseNavigationController handlePopupButtonForFile:popupFile];
}


- (NSString*) popupFile {
    
    return [self _popupFileForCurrentPage];
}


- (NSString*) _popupFileForCurrentPage {
    
    if (_mode == Vocabularies) {
    
        VocabFlowVocabularyPageViewController* controller = (VocabFlowVocabularyPageViewController*)_pageViewController.viewControllers[0];
        
        Vocabulary* vocabulary = controller.vocabulary;
        NSString* popupFile = vocabulary.popupFile;
        
        return popupFile;
    }
    else return nil;
}



#pragma mark - Delegate, Datasource

- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    VocabFlowPageViewController* controller = (VocabFlowPageViewController*)viewController;
    uint pageIndex = controller.pageIndex;
    VocabFlowPageViewController* nextController = nil;
    
    if (pageIndex > 0) {
        
        nextController = _pages[pageIndex - 1];
    }
    
    NSLog(@"next controller: %@ (index: %d)", nextController, nextController.pageIndex);
    
    return nextController;
}


- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {

    VocabFlowPageViewController* controller = (VocabFlowPageViewController*)viewController;
    uint pageIndex = controller.pageIndex;
    VocabFlowPageViewController* nextController = nil;

    if (pageIndex < _pages.count - 1) {
        
        nextController = _pages[pageIndex + 1];
    }

    NSLog(@"next controller: %@ (index: %d)", nextController, nextController.pageIndex);
    
    return nextController;
}


//- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//    
//    return _pages.count;
//}
//
//
//- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
//    
//    return _currentPage;
//}


- (void) pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {

    //
//    NSLog(@"will trans -> pend_controller: %@ (index: %d)", controller, controller.pageIndex);

//    _currentPage = controller.pageIndex;
//    self.pageControl.currentPageIndex = _currentPage;
    
    
    
}


- (void) pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {

    
//    NSLog(@"will trans -> prev_controller: %@ (index: %d)", controller, controller.pageIndex);
    
    if (completed) {

        VocabFlowPageViewController* controller = (VocabFlowPageViewController*)_pageViewController.viewControllers[0];

        _currentPage = controller.pageIndex;
        self.pageControl.currentPageIndex = _currentPage;
        
        [self _updateBottomButton];
    }
    
    
    if (_mode == Vocabularies) {
        
        NSString* popupFile = [self _popupFileForCurrentPage];
        
        [self _updatePopupButtonWithFile:popupFile];
    }

}


- (void) _updateBottomButton {
    
    if (_currentPage == _pages.count - 1) {
        
        [self.exerciseNavigationController setBottomButtonHidden:NO animated:YES];
        
        [self _assignScore];
    }
    else {
        
        [self.exerciseNavigationController setBottomButtonHidden:YES animated:YES];
    }
}



#pragma mark - Score

- (void) _assignScore {
    
    if (_scoreAssigned) return;
    
    
    NSInteger score = _pages.count;
    NSInteger maxScore = score;
    
    [self setScore:score ofMaxScore:maxScore];
    
    _scoreAssigned = YES;
}




#pragma mark - Stop

- (void) stop {
    
    [super stop];
    
}

@end
