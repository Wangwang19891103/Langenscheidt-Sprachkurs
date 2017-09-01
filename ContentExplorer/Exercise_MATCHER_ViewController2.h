//
//  Exercise_SNAKE_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "HorizontalMatcherView.h"
#import "ExerciseContentViewController.h"


@interface Exercise_MATCHER_ViewController2 : ExerciseContentViewController


@property (nonatomic, strong) IBOutlet UITextView* textView;

@property (strong, nonatomic) IBOutlet UITextView *topTextView;

@property (strong, nonatomic) IBOutlet HorizontalMatcherView *matcherView;

@end
