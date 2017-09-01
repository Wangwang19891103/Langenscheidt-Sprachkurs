//
//  Exercise_SCR_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 17.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseDragAndDropView.h"
#import "ExerciseContentViewController.h"


@interface Exercise_SCR_ViewController2 : ExerciseContentViewController


@property (nonatomic, strong) IBOutlet UITextView* textView;

@property (strong, nonatomic) IBOutlet UITextView *topTextView;

@property (nonatomic, strong) IBOutlet ExerciseDragAndDropView* dndView;

@end
