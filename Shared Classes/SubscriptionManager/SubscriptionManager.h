//
//  SubscriptionManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 18.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;
#import "SettingsManager.h"

@class RestoreProductsHandler;






extern NSString* const kSubscriptionManagerErrorDomain;

extern NSInteger const kSubscriptionManagerErrorNoInternet;



@protocol SubscriptionManagerObserver;




@interface SubscriptionManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    
    SettingsManager* _settingsManager;
    
    NSArray* _productDicts;
    
    SKProduct* _productToPurchase;
    
    /** This boolean is a light-weight storage for the current subscription state */
    BOOL _subscriptionActive;
    
//    NSDate* _nextUpdateDate;

//    __block BOOL _requestingUpdateExpirationDate;
    
    RestoreProductsHandler* _restoreHandler;
    
    /** This boolean stores the date of the last attempted (might have failed) receipt validation */
    NSDate* _lastValidationAttempt;
}

@property (nonatomic, strong) NSMutableArray* observers;

@property (nonatomic, strong) NSArray* products;

@property (nonatomic, readonly) BOOL purchasing;

@property (nonatomic, readonly) BOOL requestingUpdateExpirationDate;


+ (instancetype) instance;


- (BOOL) hasActiveSubscription;

- (void) requestUpdateHasActiveSubscriptionForceValidation:(BOOL) forceValidation;

- (void) loadProducts;

- (NSString*) activeProductIdentifier;

- (NSDate*) currentExpirationDate;

- (void) purchaseProduct:(SKProduct*) product;

- (NSString*) titleForProduct:(SKProduct*) product;

- (NSString*) titleForProductID:(NSString*) productID;

- (NSString*) longTitleForProductID:(NSString*) productID;

- (NSString*) priceForProduct:(SKProduct*) product;

- (NSString*) descriptionForProduct:(SKProduct*) product;

- (NSString*) description2ForProduct:(SKProduct*) product;

- (NSNumber*) monthsForProduct:(SKProduct*) product;

- (BOOL) isTopSellerForProduct:(SKProduct*) product;

- (BOOL) isTopPriceForProduct:(SKProduct*) product;

- (BOOL) isEarlyBirdForProduct:(SKProduct*) product;


//- (void) getSubscriptionStatus;

- (void) restoreProductsWithParentViewController:(UIViewController*) parentController;

- (void) removeRestoreHandler;

- (void) requestRestoreProducts;



#pragma mark - Observers

- (void) addObserver:(id<SubscriptionManagerObserver>)observer;

- (void) removeObserver:(id<SubscriptionManagerObserver>)observer;


@end




@protocol SubscriptionManagerObserver <NSObject>

- (void) subscriptionManagerDidLoadProducts:(NSArray*) products;

- (void) subscriptionManagerDidBeginPurchasingProduct:(SKProduct*) product;


- (void) subscriptionManagerDidFinishPurchasingProduct:(SKProduct*) product;

- (void) subscriptionManagerPurchaseFailedForProduct:(SKProduct*) product;

//- (void) subscriptionManagerDidUpdateSubscriptionStatus;

//- (void) subscriptionManagerDidDetermineSubscriptionStatus;

- (void) subscriptionManagerDidReportError:(NSError*) error;

- (void) subscriptionManagerRestoreCompletedSuccessfully;

- (void) subscriptionManagerRestoreFailedWithError:(NSError*) error;

- (void) subscriptionManagerDidUpdateSubscriptionStatusValidating:(BOOL) validating;

- (BOOL) shouldHandleSubscriptionManagerEvents;

@end