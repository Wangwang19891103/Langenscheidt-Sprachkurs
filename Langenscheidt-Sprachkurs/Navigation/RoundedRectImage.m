//
//  RoundedRectImage.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "RoundedRectImage.h"

@implementation RoundedRectImage


+ (UIImage*) roundedRectImageWithColor:(UIColor*) color cornerRadius:(CGFloat) cornerRadius borderWidth:(CGFloat) borderWidth borderColor:(UIColor*) borderColor {
    
    CGRect rect = CGRectMake(0, 0, cornerRadius * 2 + 1, cornerRadius * 2 + 1);
    CGRect smallerRect = CGRectMake(rect.origin.x + borderWidth, rect.origin.y + borderWidth, rect.size.width - borderWidth * 2, rect.size.height - borderWidth * 2);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);

    if (borderColor) {
        
        // fill border color (full rect)
        CGContextSetFillColorWithColor(context, borderColor.CGColor);
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
        [path fillWithBlendMode:kCGBlendModeNormal alpha:1.0];
        
        // fill foreground color (smaller rect)
        CGContextSetFillColorWithColor(context, color.CGColor);
        UIBezierPath* path2 = [UIBezierPath bezierPathWithRoundedRect:smallerRect cornerRadius:cornerRadius];
        [path2 fillWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
    else {
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
        [path fillWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }

    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImage* resizableImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius) resizingMode:UIImageResizingModeStretch];
    
    return resizableImage;
}




@end
