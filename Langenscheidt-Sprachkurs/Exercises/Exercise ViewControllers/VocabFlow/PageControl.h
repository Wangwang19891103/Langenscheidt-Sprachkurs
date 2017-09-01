//
//  PageControl.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 15.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;



@interface PageControl : UIView {

    NSMutableArray* _pageDots;
    UIView* _innerView;
}


@property (nonatomic, strong) IBInspectable UIColor* neutralDotColor;

@property (nonatomic, strong) IBInspectable UIColor* activeDotColor;

@property (nonatomic, assign) IBInspectable NSInteger numberOfPages;

@property (nonatomic, assign) IBInspectable NSInteger currentPageIndex;

- (void) createView;

@end



@interface PageControlDot : UIView

@property (nonatomic, strong) UIColor* neutralColor;

@property (nonatomic, strong) UIColor* activeColor;

@property (nonatomic, assign) BOOL active;

@end