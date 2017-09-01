//
//  ProgressBar.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


IB_DESIGNABLE


@interface ProgressBar : UIView

@property (nonatomic, assign) IBInspectable CGFloat percentage;

@property (nonatomic, strong) IBInspectable UIColor* barForegroundColor;

@property (nonatomic, strong) IBInspectable UIColor* barBackgroundColor;

@end
