//
//  ContentManagerInstallPopupView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 13.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ContentManagerInstallPopupView.h"
#import "RoundedRectImage.h"

#define BACKGROUND_COLOR        [UIColor whiteColor]
#define CORNER_RADIUS       5.0
#define INSETS      UIEdgeInsetsMake(CORNER_RADIUS,CORNER_RADIUS,CORNER_RADIUS,CORNER_RADIUS)



@implementation ContentManagerInstallPopupView


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.backgroundColor = [UIColor whiteColor];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowPath = shadowPath.CGPath;
    
    self.layer.cornerRadius = 5.0;
    
    
    return self;
}




//- (void) drawRect:(CGRect)rect {
//
//    
//    [super drawRect:rect];
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // clear background
//    CGContextClearRect(context, rect);
//    
//    // fill background color
//    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
//    CGContextFillRect(context, rect);
//    
//    UIImage* image = [[RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR cornerRadius:CORNER_RADIUS borderWidth:0 borderColor:nil] resizableImageWithCapInsets:INSETS resizingMode:UIImageResizingModeStretch];
//    
//    [image drawInRect:rect];
//}


@end
