//
//  HelpCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 04.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface HelpCell : UITableViewCell


@property (nonatomic, copy) void(^buttonBlock)();

- (IBAction) actionButton;

@end
