//
//  LineLayoutView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


IB_DESIGNABLE


@interface LineLayoutView : UIView {
    
//    NSMutableArray* _layoutedSubviews;
}

@property (nonatomic, assign) CGFloat horizontalSpacing;

@property (nonatomic, assign) CGFloat verticalSpacing;

@property (nonatomic, assign) NSLayoutFormatOptions verticalAlignment;

@property (nonatomic, assign) BOOL constrainSubviewWidth;


- (void) initialize;

- (void) addSubview:(UIView *)subview animated:(BOOL) animated;

- (void) removeSubview:(UIView *)subview animated:(BOOL) animated;

- (void) addUnlayoutedSubview:(UIView*) subview;

- (void) addNonBreakingSpaceWithWidth:(CGFloat) width;



#pragma mark - Subclassing

- (BOOL) respectSubviewForLineLayout:(UIView*) subview;

@end
