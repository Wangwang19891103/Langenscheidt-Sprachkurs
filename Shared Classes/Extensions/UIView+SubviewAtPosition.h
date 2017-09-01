//
//  UIView+SubviewAtPosition.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 28.01.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface UIView (SubviewAtPosition)


- (NSArray*) subviewsAtPosition:(CGPoint) position;

- (NSArray*) subviewsIntersectingRect:(CGRect) rect;

@end
