//
//  ExercisePopupViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExercisePopupViewController.h"





@implementation ExercisePopupViewController

@synthesize closeBlock;


- (id) initWithFile:(NSString*) p_file {

    self = [super init];
    
    self.file = p_file;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = YES;

    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _effectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_effectView];
    
    _blendView = [[UIView alloc] init];
    _blendView.translatesAutoresizingMaskIntoConstraints = NO;
    _blendView.backgroundColor = [UIColor blackColor];
    _blendView.alpha = 0.5;
    [self.view addSubview:_blendView];
    
    _popupView = [[ExercisePopupView alloc] initWithFile:self.file];
    _popupView.closeBlock = self.closeBlock;
    _popupView.lesson = self.lesson;
    [self.view addSubview:_popupView];
    

    
    [_popupView createView];
}


- (void) updateViewConstraints {

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_effectView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_effectView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_effectView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_effectView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_popupView]-(10)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_popupView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[_popupView]-(20)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_popupView)]];

    
    
    [super updateViewConstraints];
}



- (BOOL) prefersStatusBarHidden {
    
    return YES;
}






@end
