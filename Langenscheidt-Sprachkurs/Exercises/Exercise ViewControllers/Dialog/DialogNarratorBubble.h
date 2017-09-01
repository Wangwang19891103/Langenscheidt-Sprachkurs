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




@interface DialogNarratorBubble : UIView {
    
    UILabel* _lang1Label;
    UIView* _separatorView;
    UILabel* _lang2Label;
    
}

@property (nonatomic, copy) NSString* textLang1;

@property (nonatomic, copy) NSString* textLang2;

@property (nonatomic, assign) BOOL rasterize;

- (void) createView;

@end
