//
//  PearlCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import  UIKit;
#import "Pearl.h"


@interface PearlCellDialog : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, assign) Pearl* pearl;

@end
