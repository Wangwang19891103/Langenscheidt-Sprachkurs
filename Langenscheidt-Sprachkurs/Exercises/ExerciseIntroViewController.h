//
//  ExerciseIntroViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExerciseIntroView.h"
#import "RoundedRectButton.h"
#import "ProgressRing.h"
#import "Pearl.h"
#import "Lesson.h"


@interface ExerciseIntroViewController : UIViewController {
    
    UIVisualEffectView* _effectView;
    UIView* _blendView;
}

@property (nonatomic, strong) void(^closeBlock)();

@property (nonatomic, strong) void(^backBlock)();

@property (strong, nonatomic) IBOutlet ExerciseIntroView *exerciseIntroView;

@property (strong, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet RoundedRectButton *bottomButton;

@property (strong, nonatomic) IBOutlet ProgressRing *progressRing;

@property (strong, nonatomic) IBOutlet UILabel *pearlTitle;

@property (strong, nonatomic) IBOutlet UILabel *lessonTitle;

@property (strong, nonatomic) IBOutlet UILabel *topTitle;


@property (nonatomic, assign) Pearl* pearl;


- (IBAction)actionBack:(id)sender;

- (IBAction)actionBottomButton:(id)sender;

@end
