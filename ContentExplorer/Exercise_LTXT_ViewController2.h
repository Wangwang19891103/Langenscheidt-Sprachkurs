//
//  Exercise_LTXT_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseContentViewController.h"
//#import "ExerciseTextView.h"
#import "StackView.h"



@interface Exercise_LTXT_ViewController2 : ExerciseContentViewController  <UITextFieldDelegate> {
    
}

@property (nonatomic, strong) IBOutlet UITextView*topTextView;

//@property (nonatomic, strong) IBOutlet ExerciseTextView* prototypeTextView;

@property (nonatomic, strong) IBOutlet StackView* contentStackView;



- (id) init;

@end
