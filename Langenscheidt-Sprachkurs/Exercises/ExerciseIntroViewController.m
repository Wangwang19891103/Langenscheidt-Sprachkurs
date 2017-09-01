//
//  ExerciseIntroViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExerciseIntroViewController.h"
#import "UILabel+HTML.h"
#import "UserProgressManager.h"
#import "PearlTitle.h"


@implementation ExerciseIntroViewController


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.opaque = NO;
    self.view.translatesAutoresizingMaskIntoConstraints = YES;

    _blendView = [[UIView alloc] init];
    _blendView.translatesAutoresizingMaskIntoConstraints = NO;
    _blendView.backgroundColor = [UIColor blackColor];
    _blendView.alpha = 0.5;
//    [self.view addSubview:_blendView];
    [self.view insertSubview:_blendView belowSubview:self.exerciseIntroView];

    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _effectView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addSubview:_effectView];
    [self.view insertSubview:_effectView belowSubview:_blendView];
    
    
//    _popupView = [[ExercisePopupView alloc] initWithFile:self.file];
//    _popupView.closeBlock = self.closeBlock;
//    [self.view addSubview:_popupView];
    
    
    
//    [_popupView createView];
    
    
    [self _populateIntroView];
}


- (void) _populateIntroView {
    
    self.lessonTitle.text = self.pearl.lesson.title;
    [self.lessonTitle parseHTML];
    
    self.pearlTitle.text = [PearlTitle titleForPearl:self.pearl];
    [self.pearlTitle parseHTML];
    
    CGFloat progress = [[UserProgressManager instance] progressForPearl:self.pearl];
    self.progressRing.percentage = progress;
    
    
    // top title
    
    NSString* topTitleString = nil;
    
    if (progress > 0 && progress < 1.0) {
        
        topTitleString = @"Zuletzt bearbeitet";
    }
    else {
    
        topTitleString = @"Nächste Lerneinheit";
    }
    
    self.topTitle.text = topTitleString;
}


- (void) updateViewConstraints {
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_effectView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_effectView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_effectView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_effectView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_blendView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_blendView)]];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[_popupView]-(10)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_popupView)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[_popupView]-(20)-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(_popupView)]];
    
    
    
    [super updateViewConstraints];
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


- (IBAction)actionBack:(id)sender {
    
    NSLog(@"back");
    
    self.backBlock();
}

- (IBAction)actionBottomButton:(id)sender {
    
    self.closeBlock();
}

@end
