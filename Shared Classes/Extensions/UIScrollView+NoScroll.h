//
//  UIScrollView+NoScroll.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 07.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface UIScrollView (NoScroll)

- (void) scrollRectToVisible2:(CGRect)rect animated:(BOOL)animated;

@end
