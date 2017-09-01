//
//  HorizontalMatcherView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 21.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
//#import "HorizontalMatcherLabel.h"
#import "MatcherLabel.h"




@interface HorizontalMatcherView : UIView {
    
    NSArray* _leftButtons;
    NSMutableArray* _rightButtons;
    
    NSMutableDictionary* _pairDict;
    
    UIView<ReorderableViewProtocol>* _draggedView; // the original view
    UIView* _dragView;  // the drag proxy
    
    NSInteger _scoreAfterCheck;
    NSInteger _maxScore;
}

@property (nonatomic, strong) NSArray* pairs;

@property (nonatomic, readonly) BOOL animating;


- (void) createView;

- (BOOL) check;

- (NSArray*) correctionStrings;


#pragma mark - Score

- (NSInteger) scoreAfterCheck;
- (NSInteger) maxScore;


@end
