//
//  LineLayoutView3.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 08.03.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;



@protocol LineLayoutViewDelegate;



@interface LineLayoutView3 : UIView {
    
    CGFloat _maxLineWidth;

    UIView* _currentSubview;
    int _currentSubviewIndex;

    NSMutableArray* _subviewsToPlace;
    NSMutableArray* _placedLineLayoutedSubviewStack;
    NSMutableArray* _allPlacedSubviews;

    UIView* _highestViewInPreviousLine;
    UIView* _highestViewInCurrentLine;
    UIView* _previousViewInCurrentLine;
    
    
    // non reset
    
    int _previousWidth;
    BOOL _waitingForLayout;
    BOOL _finishedLayouting;

}

@property (nonatomic, assign) CGFloat horizontalSpacing;

@property (nonatomic, assign) CGFloat verticalSpacing;

@property (nonatomic, assign) NSLayoutFormatOptions verticalAlignment;

@property (nonatomic, assign) BOOL constrainSubviewWidth;

@property (nonatomic, assign) id<LineLayoutViewDelegate> delegate;


- (void) initialize;

- (void) addNonBreakingSpaceWithWidth:(CGFloat) width;

- (void) addConnectionToken;

- (BOOL) viewIsControlToken:(UIView*) view;


@end



@protocol LineLayoutViewDelegate <NSObject>

- (BOOL) respectSubviewForLineLayout:(UIView*) subview;

- (NSArray*) lineLayoutView:(LineLayoutView3*) layoutView customLayoutConstraintsForSubview:(UIView*) subview;

@end