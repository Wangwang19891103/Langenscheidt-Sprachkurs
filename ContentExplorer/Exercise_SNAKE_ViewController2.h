//
//  Exercise_SNAKE_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "SnakeView.h"
#import "ExerciseContentViewController.h"


@interface Exercise_SNAKE_ViewController2 : ExerciseContentViewController


@property (nonatomic, strong) IBOutlet UITextView* textView;

@property (strong, nonatomic) IBOutlet UITextView *topTextView;

@property (strong, nonatomic) IBOutlet SnakeView *snakeView;

@end
