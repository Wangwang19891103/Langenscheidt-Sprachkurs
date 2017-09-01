//
//  LineLayoutView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;



@protocol LineLayoutViewDelegate;




IB_DESIGNABLE


@interface LineLayoutView2 : UIView {
    
//    NSMutableArray* _layoutedSubviews;
    
    CGRect _previousFrame;
    
    NSMutableArray* _subviewsToLayout;
}

@property (nonatomic, assign) CGFloat horizontalSpacing;

@property (nonatomic, assign) CGFloat verticalSpacing;

@property (nonatomic, assign) NSLayoutFormatOptions verticalAlignment;

@property (nonatomic, assign) BOOL constrainSubviewWidth;

@property (nonatomic, assign) id<LineLayoutViewDelegate> delegate;


- (void) initialize;

- (void) addSubview:(UIView *)subview animated:(BOOL) animated;

- (void) removeSubview:(UIView *)subview animated:(BOOL) animated;

- (void) addCustomLayoutedSubview:(UIView*) subview;

- (void) addNonBreakingSpaceWithWidth:(CGFloat) width;

- (void) addConnectionToken;



#pragma mark - Subclassing

- (BOOL) respectSubviewForLineLayout:(UIView*) subview;

@end





@protocol LineLayoutViewDelegate <NSObject>

- (BOOL) respectSubviewForLineLayout:(UIView*) subview;

- (NSArray*) lineLayoutView:(LineLayoutView2*) layoutView customLayoutConstraintsForSubview:(UIView*) subview;

@end