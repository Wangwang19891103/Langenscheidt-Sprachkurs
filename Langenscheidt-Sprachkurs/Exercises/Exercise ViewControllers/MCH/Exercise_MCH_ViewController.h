//
//  Exercise_LTXT_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseViewController.h"
#import "MCHView.h"
#import "StackView.h"
#import "DialogAudioPlayer.h"


@interface Exercise_MCH_ViewController : ExerciseViewController <MCHViewDelegate>{
    
    DialogAudioPlayer* _player;
    NSString* audioFileName;

}

@property (nonatomic, strong) MCHView* mchView;
@property (nonatomic) NSString* audioFileName;

@property (strong, nonatomic) IBOutlet StackView *contentStackView;

@property (strong, nonatomic) IBOutlet UIView *topTextContainer;
@property (strong, nonatomic) IBOutlet UILabel *topTextLabel;
@property (strong, nonatomic) IBOutlet UIView *audioButtonContainer;


- (IBAction)actionAudio:(id)sender;

@end
