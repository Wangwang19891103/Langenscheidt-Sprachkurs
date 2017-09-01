//
//  ClusterEventCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface ClusterEventCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *courseLabel;
@property (strong, nonatomic) IBOutlet UILabel *lessonLabel;
@property (strong, nonatomic) IBOutlet UILabel *pearlLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *runLabel;
@property (strong, nonatomic) IBOutlet UILabel *clusterLabel;
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
@end
