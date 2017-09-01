//
//  DialogViewControler.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Pearl.h"
#import "AudioPlayer.h"


@interface DialogViewController : UIViewController {
    
    NSArray* _dialogs;
    CGFloat _posY;
    
    UIView* _lastView;
    
    AudioPlayer* _player;
}

@property (nonatomic, assign) Pearl* pearl;

@property (nonatomic, strong) IBOutlet UILabel* prototypeSpeakerLabel;

@property (nonatomic, strong) IBOutlet UIButton* prototypeTextLang1Button;

@property (nonatomic, strong) IBOutlet UILabel* prototypeTextLang2Label;

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;

@property (nonatomic, strong) IBOutlet UIView* contentView;

- (IBAction) actionAudio:(UIButton*) sender;

@end
