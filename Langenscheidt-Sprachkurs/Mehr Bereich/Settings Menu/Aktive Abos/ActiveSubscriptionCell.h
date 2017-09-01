//
//  ActiveSubscriptionCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface ActiveSubscriptionCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UILabel* expiresLabel;

@end
