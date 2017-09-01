//
//  RoundedRectImageView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


IB_DESIGNABLE

@interface RoundedRectImageView : UIImageView

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

@property (nonatomic, strong) IBInspectable UIColor* borderColor;


- (void) update;

@end
