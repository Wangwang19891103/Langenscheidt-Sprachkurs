//
//  ABCController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExerciseNavigationBar.h"
#import "RoundedRectButton.h"
#import "Exercise.h"


@interface ABCController : UIViewController <ExerciseNavigationBarDelegate> {
    
    NSMutableArray* _exerciseViewControllers;

}


@property (strong, nonatomic) IBOutlet ExerciseNavigationBar *navigationBar;

@property (strong, nonatomic) IBOutlet UIView *navigationBarContainer;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet RoundedRectButton *bottomButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonAreaHeightConstraint;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollview;

@property (strong, nonatomic) IBOutlet UIView *exerciseContainerView;

@property (nonatomic, assign) Exercise* exercise;

@property (nonatomic, assign) uint index;

@end
