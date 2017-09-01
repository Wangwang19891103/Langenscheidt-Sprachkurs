//
//  CustomKeyboardInputViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 25.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "LineLayoutView3.h"
#import "RoundedRectButton.h"


@interface CustomKeyboardInputViewController : UIInputViewController <LineLayoutViewDelegate, UIInputViewAudioFeedback> {
    
    NSMutableArray* _letters;
    
    RoundedRectButton* _backspaceButton;
    RoundedRectButton* _enterButton;
    
}

@property (nonatomic, strong) LineLayoutView3* layoutView;

@property (nonatomic, strong) NSString* string;

@property (nonatomic, assign) UIResponder* responder;

@end
