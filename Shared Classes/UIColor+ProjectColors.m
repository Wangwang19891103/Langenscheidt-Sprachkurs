//
//  UIColor+ProjectColors.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 29.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "UIColor+ProjectColors.h"

@implementation UIColor (ProjectColors)

+ (UIColor*) projectBlueColor {
    
    return [self _colorWithRed:0 green:151 blue:189];
}


+ (UIColor*) projectYellowColor {
    
    return [self _colorWithRed:255 green:204 blue:51];
}


+ (UIColor*) projectRedColor {
    
    return [self _colorWithRed:213 green:0 blue:14];
}


+ (UIColor*) projectGreenColor {
    
    return [self _colorWithRed:51 green:172 blue:63];
}


+ (UIColor*) _colorWithRed:(float) red green:(float) green blue:(float) blue {
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

@end
