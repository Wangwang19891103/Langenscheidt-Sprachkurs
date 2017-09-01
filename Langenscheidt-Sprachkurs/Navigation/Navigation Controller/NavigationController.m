//
//  NavigationController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//
#import "NavigationController.h"


#define NAVIGATION_BAR_ALPHA        0.4f



@implementation NavigationController

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    [self _initialize];
    
    return self;
}


- (id) init {
    
    self = [super init];
    
    [self _initialize];
    
    return self;
}


- (void) _initialize {
    
    
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [(UIView*)self.navigationBar.subviews[0] setAlpha:NAVIGATION_BAR_ALPHA];
    self.navigationBar.titleTextAttributes = @{
                                               NSForegroundColorAttributeName : [UIColor whiteColor],
                                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:17]
                                               };
    
//    [self _addStatusBarBackgroundView];
}


//- (void) _addStatusBarBackgroundView {
//
//    _backgroundView = [[UIView alloc] init];
//    _backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0f];
//    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [self.view addSubview:_backgroundView];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_backgroundView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_backgroundView)]];
//
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_backgroundView(20)]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_backgroundView)]];
//}


- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    
}


- (UIViewController*) popViewControllerAnimated:(BOOL)animated {
    
    if (self.viewControllers.count == 1) {
        
        UIViewController* poppedController = self.topViewController;
        NSMutableArray* stack = [NSMutableArray array];  // empty array
        [self setViewControllers:stack animated:animated];
        
        return poppedController;
    }
    else {
        
        return [super popViewControllerAnimated:animated];
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}


//- (void) setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
//    
//    BOOL isHidden = self.navigationBarHidden;
//    BOOL shouldHide = hidden;
//    
//    if (!isHidden && shouldHide) {
//        
//        _backgroundView.hidden = YES;
//    }
//    else if (isHidden && !shouldHide) {
//        
//        _backgroundView.hidden = NO;
//    }
//
//    
//    [super setNavigationBarHidden:hidden animated:animated];
//}


- (void) forcePushViewController:(UIViewController*) viewController {
    
    NSMutableArray* controllers = [self.viewControllers mutableCopy];
    [controllers addObject:viewController];
    self.viewControllers = controllers;
}


@end
