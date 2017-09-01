//
//  ShopPopupViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ShopPopupView.h"
#import "SubscriptionManager.h"


@interface ShopPopupViewController : UIViewController <SubscriptionManagerObserver>  {
    
    UIVisualEffectView* _effectView;
    ShopPopupView* _popupView;
    UIView* _blendView;
}

@property (nonatomic, strong) void(^closeBlock)();


@end
