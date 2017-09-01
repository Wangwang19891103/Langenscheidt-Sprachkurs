//
//  CourseMenuCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Lesson.h"

@interface LessonMenuCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) Lesson* lesson;

@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;

@property (strong, nonatomic) IBOutlet UIImageView *downloadImageView;
@property (strong, nonatomic) IBOutlet UIImageView *lockedImageView;

//- (void) updateProgressAsync;
- (void) updateProgressSync;

@end
