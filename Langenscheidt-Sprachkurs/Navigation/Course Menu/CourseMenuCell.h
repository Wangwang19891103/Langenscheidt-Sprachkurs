//
//  CourseMenuCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Course.h"

@interface CourseMenuCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, assign) Course* course;


- (void) updateProgressSync;

@end
