//
//  LessonCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Lesson.h"


@interface LessonCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, assign) Lesson* lesson;

@end
