//
//  ShopViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "SubscriptionManager.h"
#import "CustomAlertViewController.h"
#import "CustomAlertMessageView.h"



@interface ShopViewController : UITableViewController <SubscriptionManagerObserver> {
    
    NSArray* _products;
    
    NSDictionary* _activeProductInfo;

    BOOL _loading;
    BOOL _purchaseCompleted; // important to determine if validation errors shud be handled

    CustomAlertViewController* _alertViewController;
    
    CustomAlertMessageView* _purchasingView;
    CustomAlertMessageView* _purchaseFinishedView;
    CustomAlertMessageView* _purchaseFailedView;

    BOOL _shouldHandleEvents;
}


@property (nonatomic, assign) BOOL showActiveSubscription;

@property (nonatomic, copy) void(^purchaseCompleteBlock)();

@property (nonatomic, readonly) BOOL presentingPopup;


- (void) dismissPopupWithCompletionBlock:(void(^)()) completionBlock;


- (NSString*) _titleForProduct:(SKProduct*) product;

- (NSString*) _priceForProduct:(SKProduct*) product;

- (NSString*) _descriptionForProduct:(SKProduct*) product;

- (BOOL) _isTopSellerForProduct:(SKProduct*) product;

- (BOOL) _isTopPriceForProduct:(SKProduct*) product;



@end
