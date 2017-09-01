//
//  MenuViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "MenuViewController.h"

@implementation MenuViewController



- (void) updateHeaderWithOffsetY:(CGFloat)offsetY {
    
    [super updateHeaderWithOffsetY:offsetY];
    
//    NSLog(@"offsetY: %f", offsetY);
    
    UIImageView* imageView = self.header.imageView;
    CGFloat contentOffsetRatioY = 0;  // is a ratio, not pixel
    BOOL updateContentsRect = NO;
    
//    imageView.layer.contentsGravity = kCAGravityCenter;
//    imageView.layer.backgroundColor = [UIColor redColor].CGColor;
    
    if (offsetY > 0) {
        
//        NSLog(@"contentOffset: %f", self.tableView.contentOffset.y);
//        NSLog(@"header cap: %f", self.parallaxingHeaderCap);
        
        if (self.tableView.contentOffset.y - offsetY < self.parallaxingHeaderCap) {
            
//            NSLog(@"fucking");
            
//            contentOffsetRatioY = (offsetY / imageView.frame.size.height) * 0.5;
            contentOffsetRatioY = (offsetY / imageView.frame.size.height);
            updateContentsRect = YES;
        }
    }
    else {
        
        contentOffsetRatioY = 0;
        updateContentsRect = YES;
    }
    
//    NSLog(@"ratio: %f", contentOffsetRatioY);
    
    if (updateContentsRect) {

        imageView.layer.contentsRect = CGRectMake(0, -contentOffsetRatioY * 0.5, 1.0, 1.0);
    }
}




- (void) updateUI {
    
}

@end
