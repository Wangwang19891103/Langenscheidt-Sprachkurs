//
//  LTXTLayoutView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 11.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

IB_DESIGNABLE

@interface LTXTLayoutView : UIView

@property (nonatomic, copy) IBInspectable NSString* string;

@property (nonatomic, copy) IBInspectable NSString* fontName;

@property (nonatomic, assign) IBInspectable CGFloat fontSize;

@end
