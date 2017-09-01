//
//  ExerciseScoreViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "RoundedRectbutton.h"


@interface ExerciseScoreViewController : UIViewController

@property (nonatomic, assign) NSInteger score;

@property (nonatomic, assign) NSInteger maxScore;

@property (nonatomic, strong) void(^backBlock)();

@property (nonatomic, strong) void(^nextBlock)();

@property (nonatomic, strong) void(^restartBlock)();

@property (nonatomic, assign) BOOL showCloseButton;


@property (strong, nonatomic) IBOutlet UIImageView *circleImageView;

@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

@property (strong, nonatomic) IBOutlet UILabel *maxScoreLabel;

@property (strong, nonatomic) IBOutlet UIView *scoreView;

@property (strong, nonatomic) IBOutlet UIView *textContainer1;

@property (strong, nonatomic) IBOutlet UIView *textContainer2;

@property (strong, nonatomic) IBOutlet UIView *textContainer3;

@property (strong, nonatomic) IBOutlet UIView *textContainer4;

@property (strong, nonatomic) IBOutlet UIView *textContainer5;


@property (strong, nonatomic) IBOutlet UIButton *buttonRestart;

@property (strong, nonatomic) IBOutlet RoundedRectButton *buttonNext;

//@property (nonatomic, assign) BOOL canRestartLesson;

@property (strong, nonatomic) IBOutlet UIButton *closeButton;



- (IBAction)actionNext:(id)sender;

- (IBAction)actionBack:(id)sender;

- (IBAction)actionRestart:(id)sender;


- (void) fadeOut;

@end
