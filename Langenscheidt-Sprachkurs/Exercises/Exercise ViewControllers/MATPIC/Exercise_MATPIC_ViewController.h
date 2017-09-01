//
//  Exercise_MATPIC_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseViewController.h"
#import "MATPICView.h"
#import "StackView.h"


@interface Exercise_MATPIC_ViewController : ExerciseViewController <MATPICViewDelegate>

@property (nonatomic, strong) MATPICView* matpicView;



@property (strong, nonatomic) IBOutlet UIView *matpicContainerView;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;

@end
