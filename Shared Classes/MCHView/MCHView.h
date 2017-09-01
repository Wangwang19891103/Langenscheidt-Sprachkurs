//
//  MCHView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 30.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>


@import UIKit;


IB_DESIGNABLE



@protocol MCHViewDelegate;


@interface MCHView : UIView {
    
    NSArray* _buttons;    
}


@property (nonatomic, strong) NSArray* answers;

@property (nonatomic, assign) IBInspectable CGFloat spacing;

@property (nonatomic, readonly) NSInteger scoreAfterCheck;
@property (nonatomic, readonly) NSInteger scoreAfterCheck_Listening;

@property (nonatomic, readonly) NSInteger maxScore;
@property (nonatomic, readonly) NSInteger maxScore_Listening;

@property (nonatomic, assign) id<MCHViewDelegate> delegate;


- (void) createView;

- (BOOL) check;



@end



@protocol MCHViewDelegate <NSObject>

- (void) MCHViewButtonTapped;

@end
