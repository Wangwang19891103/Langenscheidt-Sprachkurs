//
//  RoundedRectImage.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface RoundedRectImage : NSObject

+ (UIImage*) roundedRectImageWithColor:(UIColor*) color cornerRadius:(CGFloat) cornerRadius borderWidth:(CGFloat) borderWidth borderColor:(UIColor*) borderColor;

@end
