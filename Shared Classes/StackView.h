//
//  StackView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 17.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


typedef NS_ENUM(NSInteger, StackViewSubviewOrientation) {
    StackViewSubviewOrientationUndefined,
    StackViewSubviewOrientationLeft,
    StackViewSubviewOrientationRight,
    StackViewSubviewOrientationFill
};


IB_DESIGNABLE

@interface StackView : UIView {
    
    NSMutableDictionary* _subviewDict;
}

@property (nonatomic, assign)  IBInspectable CGFloat spacing;

@property (nonatomic, assign) IBInspectable BOOL shouldStretch;

//@property (nonatomic, strong) IBOutletCollection(UIView) NSMutableArray* arrangedSubviews;

//- (void) addArrangedSubview:(UIView*) subview;
//
//- (void) removeArrangedSubview:(UIView*)subview;
//
//- (void) removeAllArrangedSubviews;

- (void) addSubview:(UIView *)view withOrientation:(StackViewSubviewOrientation) orientation;

@end
