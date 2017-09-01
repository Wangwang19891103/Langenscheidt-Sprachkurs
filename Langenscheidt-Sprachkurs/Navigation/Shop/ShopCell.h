//
//  ShopCell.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RoundedRectImageView.h"


@import UIKit;

@interface ShopCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) IBOutlet UILabel* monthLabel;

@property (nonatomic, strong) IBOutlet UILabel* priceLabel;

@property (nonatomic, strong) IBOutlet UILabel* descriptionLabel;

@property (nonatomic, assign) BOOL isTopseller;

@property (nonatomic, assign) BOOL isTopPrice;

@property (nonatomic, assign) BOOL isEarlyBird;


@property (nonatomic, strong) IBOutlet UIButton* button;

@property (nonatomic, strong) IBOutlet UIView* topSellerView;

@property (nonatomic, strong) IBOutlet UIView* topPriceView;

@property (nonatomic, strong) IBOutlet UIView* earlyBirdView;

@property (nonatomic, strong) IBOutlet RoundedRectImageView* roundedRectImageView;


@property (nonatomic, strong) void(^actionBlock)();

- (IBAction) actionButton;


@end
