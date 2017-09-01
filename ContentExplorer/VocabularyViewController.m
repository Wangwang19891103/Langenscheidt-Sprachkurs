//
//  VocabularyViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "VocabularyViewController.h"
#import "VocabularyPageViewController.h"
#import "ContentDataManager.h"
#import "PearlTitle.h"

@implementation VocabularyViewController

@synthesize pearl;


- (id) initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    self.dataSource = self;
    _pages = [NSMutableDictionary dictionary];
    
    return self;
}


- (void) setPearl:(Pearl *)p_pearl {
    
    pearl = p_pearl;
    _vocabularies = [[ContentDataManager instance] vocabulariesForPearl:pearl];
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    VocabularyPageViewController* controller = [self viewControllerAtIndex:0];
    controller.index = 0;
    [self setViewControllers:@[controller] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.navigationItem.title = [PearlTitle titleForPearl:pearl];
}


- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    VocabularyPageViewController* topController = (VocabularyPageViewController*)viewController;
    NSInteger index = topController.index;
    
    if (index >= _vocabularies.count - 1) {
        
        return nil;
    }
    else {
        
        return [self viewControllerAtIndex:index + 1];
    }
}


- (UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {

    VocabularyPageViewController* topController = (VocabularyPageViewController*)viewController;
    NSInteger index = topController.index;
    
    if (index <= 0) {
        
        return nil;
    }
    else {
        
        return [self viewControllerAtIndex:index - 1];
    }
}


- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return _vocabularies.count;
}


- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {

    return 0;
}


- (VocabularyPageViewController*) viewControllerAtIndex:(NSInteger) index {

    VocabularyPageViewController* controller = [_pages objectForKey:@(index)];
    
    if (!controller) {
    
        controller = [self.storyboard instantiateViewControllerWithIdentifier:@"VocabularyPage"];
        controller.index = index;
        controller.vocabulary = _vocabularies[index];

        [_pages setObject:controller forKey:@(index)];
        
        NSLog(@"instantiating page controller with index %ld", index);
    }
    
    return controller;
}


@end
