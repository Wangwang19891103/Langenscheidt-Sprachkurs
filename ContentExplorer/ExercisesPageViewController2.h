//
//  ExercisesPageViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Pearl.h"
#import "ExerciseTypes.h"


@interface ExercisesPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    
    NSArray* _exercises;
    NSMutableDictionary* _pages;
}

@property (nonatomic, assign) Pearl* pearl;

@property (nonatomic, assign) ExerciseType filterType;



@end
