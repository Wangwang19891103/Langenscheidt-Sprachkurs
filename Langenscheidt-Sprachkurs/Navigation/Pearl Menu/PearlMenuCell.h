//
//  PearlMenuCell.h
//  Langenscheidt-Sprachkurs
///
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "Pearl.h"
#import "ProgressRing.h"



typedef NS_ENUM(NSInteger, PearlMenuCellPosition) {

    PearlMenuCellPositionFirst,
    PearlMenuCellPositionLast,
    PearlMenuCellPositionMiddle
    
};


@interface PearlMenuCell : UITableViewCell

@property (nonatomic, assign) Pearl* pearl;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet ProgressRing *progressRing;

@property (strong, nonatomic) IBOutlet UIView *connectorTop;
@property (strong, nonatomic) IBOutlet UIView *connectorBottom;

@property (nonatomic, assign) PearlMenuCellPosition position;


- (void) updateView;
- (void) updateProgress;

@end
