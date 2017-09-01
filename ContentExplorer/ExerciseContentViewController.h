//
//  ExerciseContentViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Exercise.h"
#import "ExerciseLine.h"


@interface ExerciseContentViewController : UIViewController

@property (nonatomic, assign) Exercise* exercise;

@property (nonatomic, strong) NSArray* exerciseLines;

@property (nonatomic, assign) BOOL hasError;

@property (nonatomic, copy) NSString* errorDescription;


- (void) setErrorWithDescription:(NSString*) description;

@end
