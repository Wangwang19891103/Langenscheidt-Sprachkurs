//
//  Exercise_LTXT_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseViewController.h"
#import "SCRView.h"
#import "StackView.h"


@interface Exercise_SCR_ViewController : ExerciseViewController

@property (nonatomic, strong) SCRView* scrView;

@property (strong, nonatomic) IBOutlet StackView *contentStackView;

@property (strong, nonatomic) IBOutlet UIView *topTextContainer;

@property (strong, nonatomic) IBOutlet UILabel *topTextLabel;

@end
