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


@interface DragAndDropInputViewController : UIInputViewController <UIInputViewAudioFeedback> {
    
    RoundedRectButton* _enterButton;

}

@property (nonatomic, strong) LineLayoutView3* layoutView;

@property (nonatomic, strong) NSArray* strings;

@property (nonatomic, assign) UIResponder* responder;

@end
