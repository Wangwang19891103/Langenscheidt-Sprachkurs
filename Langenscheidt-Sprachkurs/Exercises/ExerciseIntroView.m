//
//  ExerciseIntroView.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.04.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ExerciseIntroView.h"
#import "RoundedRectImage.h"


#define BACKGROUND_COLOR            [UIColor whiteColor]
#define CORNER_RADIUS               5.0
#define INSETS                      UIEdgeInsetsMake(CORNER_RADIUS,CORNER_RADIUS,CORNER_RADIUS,CORNER_RADIUS)


@implementation ExerciseIntroView



- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    return self;
}



#pragma mark - Draw Rect

- (void) drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // clear background
    CGContextClearRect(context, rect);
    
    // fill background color
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    UIImage* image = [[RoundedRectImage roundedRectImageWithColor:BACKGROUND_COLOR cornerRadius:CORNER_RADIUS borderWidth:0 borderColor:nil] resizableImageWithCapInsets:INSETS resizingMode:UIImageResizingModeStretch];
    
    [image drawInRect:rect];
}


@end
