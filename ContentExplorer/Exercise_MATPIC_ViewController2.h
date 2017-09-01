//
//  Exercise_MATPIC_ViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 28.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseContentViewController.h"
#import "Pearl.h"
#import "Vocabulary.h"


@interface Exercise_MATPIC_ViewController : UIViewController {
    
    NSArray* _vocabularies;
}

@property (nonatomic, strong) Pearl* pearl;

@property (nonatomic, strong) IBOutlet UITextView* textView;

@property (strong, nonatomic) IBOutlet UILabel *vocabularyLabel;
@end
