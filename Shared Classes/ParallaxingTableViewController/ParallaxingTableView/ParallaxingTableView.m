//
//  ParallaxingTableView.m
//  TTZSensorikTest
//
//  Created by Stefan Ueter on 10.07.14.
//  Copyright (c) 2014 stue. All rights reserved.
//

#import "ParallaxingTableView.h"



@implementation ParallaxingTableView


- (void) layoutSubviews {

    CGFloat headerOffsetY = self.tableHeaderView.frame.origin.y;
    CGFloat footerOffsetY = self.tableFooterView.frame.origin.y;
    CGFloat headerOffsetX = self.tableHeaderView.frame.origin.x;
    
    NSLog(@"offsetx: %f", headerOffsetX);
    
    [super layoutSubviews];

    
    headerOffsetX = self.tableHeaderView.frame.origin.x;
    NSLog(@"offsetx AFTER: %f", headerOffsetX);

//    [self.tableHeaderView setFrameY:headerOffsetY];
//    [self.tableHeaderView setFrameX:headerOffsetX];
//    [self.tableFooterView setFrameY:footerOffsetY];
    
    self.tableHeaderView.frame = ({
        
        CGRect newRect = self.tableHeaderView.frame;
        newRect.origin.x = headerOffsetX;
        newRect.origin.y = headerOffsetY;
        
        newRect;
    });
    
    self.tableFooterView.frame = ({
        
        CGRect newRect = self.tableFooterView.frame;
        newRect.origin.y = footerOffsetY;
        
        newRect;
    });

}



- (void) setFrame:(CGRect)frame {

    [super setFrame:frame];

    if ([self.tableHeaderView.layer animationForKey:@"position"]) {
        
        CABasicAnimation* animation = (CABasicAnimation*)[self.tableHeaderView.layer animationForKey:@"position"];
        CGPoint originalPositon = [animation.fromValue CGPointValue];
        [self.tableHeaderView.layer removeAnimationForKey:@"position"];
        self.tableHeaderView.layer.position = originalPositon;
        [self.tableHeaderView.layer removeAnimationForKey:@"position"];
    }
}

@end
