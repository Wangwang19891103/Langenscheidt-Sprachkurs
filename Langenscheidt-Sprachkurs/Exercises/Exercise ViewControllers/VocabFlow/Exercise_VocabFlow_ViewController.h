//
//  Exercise_VocabFlow_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseViewController.h"
#import "PageControl.h"


typedef NS_ENUM(NSInteger, VocabFlowMode) {
    
    Vocabularies,
    Grammar
};


@interface Exercise_VocabFlow_ViewController : ExerciseViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    
    UIPageViewController* _pageViewController;
    
    NSArray* _pages;
    int _currentPage;
    
    BOOL _scoreAssigned;
}

@property (strong, nonatomic) IBOutlet UIView *topTextContainer;
@property (strong, nonatomic) IBOutlet UILabel *topTextLabel;
@property (strong, nonatomic) IBOutlet UIView *pageControllerContainer;
@property (strong, nonatomic) IBOutlet PageControl *pageControl;
@property (nonatomic, readonly) VocabFlowMode mode;


- (NSString*) popupFile;


@end
