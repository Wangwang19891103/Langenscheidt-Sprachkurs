//
//  VocabFlowGrammarPageViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VocabFlowPageViewController.h"
#import "Vocabulary.h"
@import AVFoundation;

@interface VocabFlowVocabularyPageViewController : VocabFlowPageViewController <AVAudioPlayerDelegate> {
    
    AVAudioPlayer* _player;
}

@property (strong, nonatomic) IBOutlet UILabel *labelLang1;
@property (strong, nonatomic) IBOutlet UILabel *labelLang2;
//@property (nonatomic, assign) uint a;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *debugLabel;

@property (nonatomic, strong) Vocabulary* vocabulary;

@property (nonatomic, strong) NSDictionary* dict;


- (IBAction) actionAudio;

@end
