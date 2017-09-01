//
//  MenuViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ParallaxingTableViewController.h"
#import "TableViewHeader.h"


@interface MenuViewController : ParallaxingTableViewController

@property (strong, nonatomic) IBOutlet TableViewHeader *header;


- (void) updateUI;

@end
