//
//  ExerciseScoreViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExerciseScoreViewController.h"
#import "UIColor+ProjectColors.h"
@import AVFoundation;



@implementation ExerciseScoreViewController


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    // image
    UIImage* image = nil;
    self.textContainer1.hidden = YES;
    self.textContainer2.hidden = YES;
    self.textContainer3.hidden = YES;
    self.textContainer4.hidden = YES;
    self.textContainer5.hidden = YES;

    self.buttonRestart.hidden = YES;

    float ratio = (float)self.score / (float)self.maxScore;
    
    BOOL changeButtonDesign = NO;
    
    
    
    if (ratio <= 0.14) {
        
        image = [UIImage imageNamed:@"Score Screen Circle 74"];
        self.textContainer1.hidden = NO;
        self.buttonRestart.hidden = NO;
    }
    else if (ratio <= 0.49) {
        
        image = [UIImage imageNamed:@"Score Screen Circle 74"];
        self.textContainer2.hidden = NO;
        self.buttonRestart.hidden = NO;
    }
    else if (ratio <= 0.74) {
        
        image = [UIImage imageNamed:@"Score Screen Circle 74"];
        self.textContainer3.hidden = NO;
        changeButtonDesign = YES;
    }
    else if (ratio <= 0.99) {
        
        image = [UIImage imageNamed:@"Score Screen Circle 99"];
        self.textContainer4.hidden = NO;
        changeButtonDesign = YES;
    }
    else {  // 100% (or higher??)
        
        image = [UIImage imageNamed:@"Score Screen Circle 100"];
        self.textContainer5.hidden = NO;
        changeButtonDesign = YES;
    }
    
    self.circleImageView.image = image;

    
    if (changeButtonDesign) {
        
        _buttonNext.tintColor = [UIColor projectBlueColor];
        _buttonNext.borderWidth = 0;
        [_buttonNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _buttonNext.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    }
    
    
    // show/hide close button
    
    _closeButton.hidden = !_showCloseButton;
    
    
    
    // score
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", self.score];
    self.maxScoreLabel.text = [NSString stringWithFormat:@"VON %ld", self.maxScore];
    
    
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self _playSound];
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


- (void) fadeOut {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.scoreView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
//        self.view.alpha = 0.0;
    }];
}



- (void) _playSound {
    
    NSURL* soundsURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds"];
    NSURL* URL = [soundsURL URLByAppendingPathComponent:@"nano/Alarm_Nightstand_Haptic.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)URL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}



- (IBAction)actionNext:(id)sender {

    self.nextBlock();
}


- (IBAction)actionBack:(id)sender {
    
    self.backBlock();
}

- (IBAction)actionRestart:(id)sender {
    
    self.restartBlock();
}


@end
