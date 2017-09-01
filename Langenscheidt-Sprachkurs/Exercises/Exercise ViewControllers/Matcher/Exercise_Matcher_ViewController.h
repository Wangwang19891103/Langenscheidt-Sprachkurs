//
//  Exercise_LTXT_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseViewController.h"
#import "HorizontalMatcherView.h"
#import "StackView.h"


@interface Exercise_Matcher_ViewController : ExerciseViewController

@property (nonatomic, strong) HorizontalMatcherView* matcherView;

@property (strong, nonatomic) IBOutlet StackView *contentStackView;

@end
