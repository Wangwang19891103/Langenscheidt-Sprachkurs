//
//  CourseCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 29.10.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Course.h"

@interface CourseCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, assign) Course* course;

@end
