//
//  AnalyticsCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface AnalyticsCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UISwitch* analyticsSwitch;

@property (nonatomic, assign) BOOL activated;

@property (nonatomic, copy) void(^buttonBlock)(BOOL active);

- (IBAction) actionAnalytics;

@end
