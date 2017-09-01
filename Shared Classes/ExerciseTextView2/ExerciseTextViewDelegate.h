//
//  ExerciseTextViewDelegate.h
//  PONS-Sprachkurs-Universal
//
//  Created by Stefan Ueter on 27.03.14.
//  Copyright (c) 2014 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@class ExerciseTextView;

@protocol ExerciseTextViewDelegate <NSObject>

- (UIView*) exerciseTextView:(ExerciseTextView*) textView viewForGapString:(NSString*) string;

@end
