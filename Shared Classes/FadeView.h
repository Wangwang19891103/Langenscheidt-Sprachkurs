//
//  ScrollView.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 18.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


typedef NS_ENUM(NSInteger, FadeViewCurve) {
    
    Linear,
    Sinus,
    Cubic
};

@interface FadeView : UIView {
    
    CALayer* _maskLayer;
    CAGradientLayer* _layerTop;
    CAGradientLayer* _layerBottom;
    CALayer* _middleLayer;
}


@property (nonatomic, assign) IBOutlet UIView* viewToFade;

@property (nonatomic, assign) IBOutlet UIView* topLimitView;

@property (nonatomic, assign) IBOutlet UIView* bottomLimitView;

//@property (nonatomic, assign) IBInspectable CGFloat topHeight;

//@property (nonatomic, assign) IBInspectable CGFloat bottomHeight;

@property (nonatomic, assign) IBInspectable CGFloat adjustmentTopLimit;

@property (nonatomic, assign) IBInspectable CGFloat adjustmentBottomLimit;

@property (nonatomic, assign) IBInspectable CGFloat adjustmentTopReach;

@property (nonatomic, assign) IBInspectable CGFloat adjustmentBottomReach;

@property (nonatomic, assign) IBInspectable CGFloat minimumAlpha;

@property (nonatomic, assign) BOOL enabled;


- (void) createView;

@end
