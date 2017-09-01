//
//  MatcherLabel.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 02.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ReorderableViewProtocol.h"

typedef NS_ENUM(NSInteger, MatcherLabelOrientation)  {
    
    Left,
    Right
};


typedef NS_ENUM(NSInteger, MatcherLabelState) {
    
    Normal,
    Selected,
    Correct,
    Wrong,
    Immovable,
    Ghost
};


@interface MatcherLabel : UIView  <ReorderableViewProtocol>{
    
    UILabel* _label;
}

@property (nonatomic, copy) NSString* string;

@property (nonatomic, assign) MatcherLabelOrientation orientation;

@property (nonatomic, assign) MatcherLabelState state;

- (void) createView;

@end
