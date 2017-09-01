//
//  VocabularyPageViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Vocabulary.h"


@interface VocabularyPageViewController : UIViewController

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) Vocabulary* vocabulary;

@property (nonatomic, strong) IBOutlet UILabel* label1;
@property (nonatomic, strong) IBOutlet UILabel* label2;

@end
