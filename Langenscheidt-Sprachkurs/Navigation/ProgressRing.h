//
//  ProgressRing.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

IB_DESIGNABLE


@interface ProgressRing : UIView


@property (nonatomic, assign) IBInspectable CGFloat percentage;

@property (nonatomic, assign) IBInspectable CGFloat lineWidth;

@property (nonatomic, strong) IBInspectable UIColor* ringForegroundColor;

@property (nonatomic, strong) IBInspectable UIColor* ringBackgroundColor;

@property (nonatomic, copy) IBInspectable NSString* fontName;

@property (nonatomic, assign) IBInspectable CGFloat fontSize;

@property (nonatomic, assign) IBInspectable CGFloat smallFontSize;

@property (nonatomic, strong) IBInspectable UIColor* textColor;


@end
