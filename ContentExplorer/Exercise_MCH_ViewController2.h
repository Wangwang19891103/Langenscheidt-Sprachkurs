//
//  Exercise_MCH_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExerciseContentViewController.h"
#import "MCHView.h"


@interface Exercise_MCH_ViewController2 : ExerciseContentViewController


@property (nonatomic, strong) IBOutlet UITextView* textView;

@property (strong, nonatomic) IBOutlet UITextView *topTextView;

@property (strong, nonatomic) IBOutlet MCHView *mchView;

@end
