//
//  CustomAlertView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 23.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "CustomAlertViewController.h"


@implementation CustomAlertViewController

- (id) init {
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"CustomAlertViewController" bundle:[NSBundle mainBundle]];
    
    self = [storyboard instantiateInitialViewController];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self _layoutStepViews];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    _blendView = [[UIView alloc] init];
    _blendView.translatesAutoresizingMaskIntoConstraints = NO;
    _blendView.backgroundColor = [UIColor blackColor];
    _blendView.alpha = 0.3;
    [self.view insertSubview:_blendView belowSubview:self.containerView];
    
    [self showContentView:_contentViews[0] animated:NO];
}


- (void) _layoutStepViews {
    
    for (UIView* contentView in _contentViews) {
        
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
}


- (void) showContentView:(UIView*) stepView animated:(BOOL) animated {
    
    NSLog(@"CustomAlertViewController - showContentView");
    
    if (!self.view || !self.containerView || !stepView) return;
    
    //----------------
    
    NSTimeInterval blendOutDuration = 0.2;
    NSTimeInterval resizeDuration = 0.2;
    NSTimeInterval blendInDuration = 0.2;
    
    
    
    
    // inline blocks
    
    void(^fadeOut)(UIView*, BOOL);
    __block void(^addNextView)(UIView*, BOOL);
    __block void(^resize)(UIView*, BOOL);
    __block void(^fadeIn)(UIView*, BOOL);
    
    
    fadeOut = ^void(UIView* stepView, BOOL animated) {
        
        UIView* previousView = (self.containerView.subviews.count > 0) ? self.containerView.subviews[0] : nil;
        
        if (previousView) {
            
            if (animated) {
                
                previousView.alpha = 1.0;
                
                [UIView animateWithDuration:blendOutDuration
                                 animations:^{
                                     
                                     previousView.alpha = 0.0;
                                 }
                                 completion:^(BOOL finished) {
                                     
                                     [previousView removeFromSuperview];
                                     
                                     addNextView(stepView, animated);
                                     
                                     resize(stepView, animated);
                                 }];
            }
            else {
                
                [previousView removeFromSuperview];
                
                addNextView(stepView, animated);
                
                resize(stepView, animated);
            }
        }
        else {
            
            addNextView(stepView, animated);
            
            resize(stepView, animated);
        }
    };
    
    addNextView = ^void(UIView* stepView, BOOL animated) {
        
        [self.containerView addSubview:stepView];
        
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[stepView]-|" options:0 metrics:@{@"left" : @(self.containerView.layoutMargins.left), @"right" : @(self.containerView.layoutMargins.right)} views:NSDictionaryOfVariableBindings(stepView)]];
        
        [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=top)-[stepView]-(>=bottom)-|" options:0 metrics:@{@"top" : @(self.containerView.layoutMargins.top), @"bottom" : @(self.containerView.layoutMargins.bottom)} views:NSDictionaryOfVariableBindings(stepView)]];
        
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:stepView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        
        
        [stepView setNeedsLayout];
        [stepView layoutIfNeeded];
        
        stepView.alpha = 0.0;
        
        
        [self.containerView setNeedsUpdateConstraints];
    };
    
    
    resize = ^void(UIView* stepView, BOOL animated) {
        
        if (animated) {
            
            
            [UIView animateWithDuration:resizeDuration delay:0 options:0
                             animations:^{
                                 
                                 [self.containerView layoutIfNeeded];
                             }
                             completion:^(BOOL finished) {
                                 
                                 fadeIn(stepView, animated);
                             }];
        }
        else {
            
            [self.containerView layoutIfNeeded];
            
            fadeIn(stepView, animated);
        }
    };
    
    
    fadeIn = ^void(UIView* stepView, BOOL animated) {
        
        if (animated) {
            
            [UIView animateWithDuration:blendInDuration delay:0 options:0
                             animations:^{
                                 
                                 stepView.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
        else {
            
            stepView.alpha = 1.0;
        }
    };
    
    
    
    fadeOut(stepView, animated);
    
    
}


- (void) updateViewConstraints {
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];
    
    [super updateViewConstraints];
}


- (BOOL) prefersStatusBarHidden {
    
    return NO;
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

@end
