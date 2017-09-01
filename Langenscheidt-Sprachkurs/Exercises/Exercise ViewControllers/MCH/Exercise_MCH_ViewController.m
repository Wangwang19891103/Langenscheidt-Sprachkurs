//
//  Exercise_LTXT_ViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "Exercise_MCH_ViewController.h"
#import "NSString+Clean.h"
#import "UILabel+HTML.h"

#define SPACING         10


@implementation Exercise_MCH_ViewController


@synthesize mchView;
@synthesize contentStackView;




- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];

    self.canBeChecked = NO;
    self.hidesBottomButtonInitially = YES;
    
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createView];
    
}





- (void) viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
}


- (void) createView {
    
    NSString* toptext = self.exerciseDict[@"topText"];
    
    if (toptext) {
        
        self.topTextLabel.text = self.exerciseDict[@"topText"];
        [self.topTextLabel parseHTML];
    }
    else {
        
        [self.topTextContainer removeFromSuperview];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[contentStackView]" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(contentStackView)]];
    }

    
    
    self.mchView = [[MCHView alloc] init];
    self.mchView.delegate = self;
    self.mchView.layoutMargins = UIEdgeInsetsMake(0, 17, 0, 17);
    self.mchView.spacing = 10;

//    [self.view addSubview:self.mchView];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mchView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(mchView)]];
//    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mchView]-0-|" options:0 metrics:@{} views:NSDictionaryOfVariableBindings(mchView)]];

    
    [self.contentStackView addSubview:mchView];
    
    self.mchView.answers = [self _createAnswers];
    
    [self.mchView createView];
    
    
    // audio button container
    
    if (self.exerciseDict[@"audioFile"]) {
        
        _player = [[DialogAudioPlayer alloc] initWithExerciseDict:self.exerciseDict];
        
        _audioButtonContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentStackView addSubview:_audioButtonContainer];
        
        [_audioButtonContainer layoutIfNeeded];
    }
}


- (NSArray*) _createAnswers {
    
    NSMutableArray* answers = [NSMutableArray array];

    NSDictionary* lineDict = self.exerciseDict[@"lines"][0];
    
    if (lineDict[@"field1"]) [answers addObject:[lineDict[@"field1"] cleanString]];
    if (lineDict[@"field2"]) [answers addObject:[lineDict[@"field2"] cleanString]];
    if (lineDict[@"field3"]) [answers addObject:[lineDict[@"field3"] cleanString]];
    if (lineDict[@"field4"]) [answers addObject:[lineDict[@"field4"] cleanString]];
    if (lineDict[@"field5"]) [answers addObject:[lineDict[@"field5"] cleanString]];
    
    return answers;
}


- (void) check {
    
    [super check];
    
    BOOL correct = YES;
    
    audioFileName = self.exerciseDict[@"audioFile"];
    
    NSLog(@"audiofilename is %@",audioFileName);
    
    NSInteger score;
    NSInteger maxScore;
    
    correct = [self.mchView check];
    
    if(audioFileName == NULL){
        
        score = self.mchView.scoreAfterCheck;
        maxScore = self.mchView.maxScore;
    }
    else{
        
        score = self.mchView.scoreAfterCheck_Listening;
        
        NSLog(@"scoreAfterCheck_Listening %li",score);
        
        maxScore = self.mchView.maxScore_Listening;
    }

    [self setScore:score ofMaxScore:maxScore];
    
    if (correct) {
        
        [self playCorrectSound];
    }
    else {
        
        [self playWrongSound];
    }
    
    [self showBottomButton];
}



- (IBAction)actionAudio:(id)sender {

    [_player playExerciseAudio];
}


- (void) MCHViewButtonTapped {
    
    [self check];
}



#pragma mark - Stop

- (void) stop {
    
    [super stop];
    
    [_player stop];
}

@end
