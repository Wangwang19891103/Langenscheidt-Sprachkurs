//
//  DialogBubble.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExerciseTextView2.h"




typedef NS_ENUM(NSInteger, DialogBubbleColor) {

    Blue,
    Orange,
    Green,
    Purple,
    Brown,
    Red,
    Gray = 100
};


extern NSInteger const kDialogBubbleNarratorColor;



@interface DialogBubble : UIView {
    
    NSMutableArray* _textFields;
    UILabel* _speakerLabel;
    ExerciseTextView2* _lang1TextView;
    UIView* _separatorView;
    UILabel* _lang2Label;
    UIColor* _backgroundColor;
    
    BOOL _finishedLayouting;
}

@property (nonatomic, assign) DialogBubbleColor color;

@property (nonatomic, copy) NSString* speaker;

@property (nonatomic, assign) BOOL isNarratorBubble;

@property (nonatomic, copy) NSString* textLang1;

@property (nonatomic, copy) NSString* textLang2;

@property (nonatomic, assign) int side;

@property (nonatomic, readonly) NSArray* textFields;

@property (nonatomic, assign) BOOL rasterize;

@property (nonatomic, readonly) ExerciseTextView2* textView;

- (void) createView;

@end
