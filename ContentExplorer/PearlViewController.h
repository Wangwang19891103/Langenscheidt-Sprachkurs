//
//  PearlViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Lesson.h"
#import "ExerciseTypes.h"


@interface PearlViewController : UITableViewController {
    
    NSArray* _pearls;
}

@property (nonatomic, assign) Lesson* lesson;

@property (nonatomic, assign) ExerciseType filterType;

@end
