//
//  Exercise_LTXT_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseViewController.h"
#import "ExerciseTextView2.h"
#import "StackView.h"
#import "ExerciseCorrectionView.h"
#import "ExerciseTypes.h"
#import "TextFieldCoordinator.h"
#import "KeyboardEventManager.h"
#import "DialogAudioPlayer.h"



@interface Exercise_LTXT_ViewController : ExerciseViewController <TextFieldCoordinatorDelegate, KeyboardEventManagerObserver> {
    
    NSMutableArray* _textViews;
    
    ExerciseType _type;
    
    TextFieldCoordinator* _textFieldCoordinator;
    
    DialogAudioPlayer* _player;
}

@property (strong, nonatomic) IBOutlet UIView *topTextContainer;

@property (strong, nonatomic) IBOutlet UILabel *topTextLabel;

@property (strong, nonatomic) IBOutlet StackView *contentStackView;

@property (strong, nonatomic) IBOutlet UIView *audioButtonContainer;

//this part was added
@property (nonatomic) NSString* audioFileName;

- (IBAction)actionAudio:(id)sender;

@end
