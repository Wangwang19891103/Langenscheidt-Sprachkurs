//
//  ExerciseViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Exercise.h"

@interface ExerciseDataViewController : UIViewController

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) Exercise* exercise;


// remove later
@property (nonatomic, strong) IBOutlet UILabel* idLabel;

@property (nonatomic, strong) IBOutlet UILabel* typeLabel;
// ---

@property (nonatomic, strong) IBOutlet UITextView* instructionView;

@property (nonatomic, strong) IBOutlet UITextView* topTextView;

@property (nonatomic, strong) IBOutlet UITextView* field1View;

@property (nonatomic, strong) IBOutlet UITextView* field2View;

@property (nonatomic, strong) IBOutlet UITextView* field3View;

@property (nonatomic, strong) IBOutlet UITextView* field4View;

@property (nonatomic, strong) IBOutlet UITextView* field5View;

@property (nonatomic, strong) IBOutlet UITextView* popupFileView;

@end
