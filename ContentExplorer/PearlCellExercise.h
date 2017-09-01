//
//  PearlCellExercise.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Pearl.h"


@interface PearlCellExercise : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, assign) Pearl* pearl;

@end
