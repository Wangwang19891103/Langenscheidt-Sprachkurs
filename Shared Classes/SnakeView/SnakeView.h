//
//  SnakeView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "SnakeLabel.h"


@interface SnakeView : UIView {
    
    NSString* _randomLetters;
    NSArray* _buttons;
    
    UIView* _innerView;
    
//    UIView* _underlayView;
}


@property (nonatomic, copy) NSString* string;
@property (nonatomic, copy) NSString* prefix;

@property (nonatomic, readonly) NSInteger scoreAfterCheck;

@property (nonatomic, readonly) NSInteger maxScore;


- (void) createView;

- (BOOL) check;


@end
