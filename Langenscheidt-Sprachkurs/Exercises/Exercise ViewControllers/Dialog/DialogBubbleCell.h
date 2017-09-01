//
//  DialogBubbleCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 24.03.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DialogBubble.h"
@import UIKit;


@interface DialogBubbleCell : UITableViewCell

@property (nonatomic, strong) UIView* innerView;

+ (UIEdgeInsets) margins;


@end
