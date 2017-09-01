//
//  SubscriptionManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 18.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "SubscriptionManager.h"
#import "SubscriptionReceiptManager.h"
#import "ReachabilityManager.h"
#import "RestoreProductsHandler.h"



/* Handled Errors:
 *
 * No Internet
 *
 */



#define PRODUCT_DICTS_FILE          @"products.plist"

#define MINUTES_BEFORE_TRANSACTION_IS_OLD           5.0


// handling and storing expiration date
//#define EXPIRATION_DATE_UPDATE_INTERVAL             1.0         // in minutes
#define SETTINGS_MANAGER_INSTANCE_NAME              @"subscription"
#define SETTINGS_MANAGER_EXPIRATION_DATE_KEY        @"expiration-date"
//#define SETTINGS_MANAGER_NEXT_UPDATE_DATE_KEY       @"next-update-date"
//#define SETTINGS_MANAGER_SUBSCRIPTION_LAST_ACTIVE_KEY    @"last-active"
#define SETTINGS_MANAGER_PRODUCT_ID_KEY      @"product-id"


NSString* const kSubscriptionManagerErrorDomain = @"SubscriptionManagerErrorDomain";


NSInteger const kSubscriptionManagerErrorNoInternet = 201;




@implementation SubscriptionManager


#pragma mark - Init

+ (instancetype) instance {
    
    static SubscriptionManager* __instance = nil;
    
    @synchronized (self) {
        
        if (!__instance) {
            
            __instance = [[SubscriptionManager alloc] init];
        }
        
        return __instance;
    }
}


- (id) init {
    
    self = [super init];

    NSString* filePath = [[NSBundle mainBundle] pathForResource:PRODUCT_DICTS_FILE ofType:nil];
    _productDicts = [NSArray arrayWithContentsOfFile:filePath];
    _observers = [NSMutableArray array];
    _settingsManager = [SettingsManager instanceNamed:SETTINGS_MANAGER_INSTANCE_NAME];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    
//    [self _requestUpdateExpirationDate]; // for testing
    
    return self;
}



#pragma mark - Public Methods

//- (void) getSubscriptionStatus {  // should be called on app start
//
//    [self _updateHasActiveSubscription];
//}



- (BOOL) hasActiveSubscription {  // this method gets hammered
    
    NSLog(@"subscriptionActive: %d", _subscriptionActive);
    
    return _subscriptionActive;
}


- (void) requestUpdateHasActiveSubscription {  // this method can get called from anywhere in the app to manually check for subscription status ( for example in Pearl VC, viewwillappear)
    
    [self _updateHasActiveSubscription];
}


- (void) loadProducts {
    // can throw error

    BOOL canConnectToInternet = [self _canConnectToInternetSilent:NO];
    
    if (!canConnectToInternet) return;
    
    // ------
    
    NSMutableSet* productIDs = [NSMutableSet set];
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID = productDict[@"productID"];
        
        [productIDs addObject:productID];
    }
    
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDs];
    request.delegate = self;
    [request start];
}


- (NSString*) activeProductIdentifier {
    
    return [_settingsManager valueForKey:SETTINGS_MANAGER_PRODUCT_ID_KEY];
}


- (NSDate*) currentExpirationDate {
    
    return [_settingsManager valueForKey:SETTINGS_MANAGER_EXPIRATION_DATE_KEY];
}



#pragma mark Purchase

- (void) purchaseProduct:(SKProduct *)product {
    
    if (_purchasing) {
        
        NSLog(@"already purchasing");
        
        return;
    }
    
    
    [self _initiatePurchaseOfProduct:product];
}


#pragma mark Product Information

- (NSString*) titleForProduct:(SKProduct*) product {
    
    return [self titleForProductID:product.productIdentifier];
}


- (NSString*) titleForProductID:(NSString*) productID {
    
    NSString* title = nil;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID = productDict[@"productID"];
        
        if ([productID isEqualToString:productID]) {
            
            title = productDict[@"title"];
            
            break;
        }
    }
    
    return title;
}


- (NSString*) longTitleForProductID:(NSString*) productID {
    
    NSString* title = nil;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID = productDict[@"productID"];
        
        if ([productID isEqualToString:productID]) {
            
            title = productDict[@"longTitle"];
            
            break;
        }
    }
    
    return title;
}


- (NSString*) priceForProduct:(SKProduct*) product {
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString* formattedString = [numberFormatter stringFromNumber:product.price];
    
    return formattedString;
}


- (NSString*) descriptionForProduct:(SKProduct*) product {
    
    NSNumber* price = product.price;
    NSNumber* months = [self monthsForProduct:product];
    
    float monthlyPrice = price.floatValue / months.floatValue;
    
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString* monthlyPriceString = [numberFormatter stringFromNumber:@(monthlyPrice)];
    
    NSString* descriptionPart2 = nil;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID = productDict[@"productID"];
        
        if ([productID isEqualToString:product.productIdentifier]) {
            
            descriptionPart2 = productDict[@"description"];
            
            break;
        }
    }
    
    NSString* description = [NSString stringWithFormat:@"%@ pro Monate\n%@", monthlyPriceString, descriptionPart2];
    
    return description;
}


- (NSNumber*) monthsForProduct:(SKProduct*) product {
    
    NSNumber* months = nil;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID = productDict[@"productID"];
        
        if ([productID isEqualToString:product.productIdentifier]) {
            
            months = productDict[@"months"];
            
            break;
        }
    }
    
    return months;
}


- (BOOL) isTopSellerForProduct:(SKProduct*) product {

    BOOL isTopSeller = NO;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID = productDict[@"productID"];
        
        if ([productID isEqualToString:product.productIdentifier]) {
            
            isTopSeller = [productDict[@"isTopSeller"] boolValue];
            
            break;
        }
    }
    
    return isTopSeller;
}


- (BOOL) isTopPriceForProduct:(SKProduct*) product {
    
    BOOL isTopPrice = NO;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID = productDict[@"productID"];
        
        if ([productID isEqualToString:product.productIdentifier]) {
            
            isTopPrice = [productDict[@"isTopPrice"] boolValue];
            
            break;
        }
    }
    
    return isTopPrice;
}



#pragma mark - Restore Products

- (void) restoreProductsWithParentViewController:(UIViewController*) parentController {
    
    _restoreHandler = [[RestoreProductsHandler alloc] init];
                       
    [_restoreHandler presentPopupWithParentViewController:parentController];
}


- (void) requestRestoreProducts {  // called from handler class
    
    [self _restoreProducts];
}


- (void) _restoreProducts {
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}




#pragma mark - Check Active Subscription

- (void) _updateHasActiveSubscription {

    NSLog(@"SubscriptionManager - updateHasActiveSubscription");
    
//    _nextUpdateDate = [_settingsManager valueForKey:SETTINGS_MANAGER_NEXT_UPDATE_DATE_KEY];

    BOOL newStatus = [self _checkActiveSubscription];  // should receive the result of medium check (expiration date) and if needed initiates expiration date update check (with async report of new state)
    
    // must report subscription status to observers
    
    BOOL statusChanged = newStatus != _subscriptionActive;
    
    NSLog(@"SubscriptionManager - updateHasActiveSubscription (old state: %d, new state: %d, changed: %d)", _subscriptionActive, newStatus, statusChanged);
    
    _subscriptionActive = newStatus;
    
    if (statusChanged) {
        
        [self _reportSubscriptionStatusUpdated];
    }
    
    [self _reportSubscriptionStatusDetermined];
}


- (BOOL) _checkActiveSubscription {

    NSLog(@"checking active subscription");
    
    BOOL hasActiveSubscription;

    BOOL expirationDatePresent = [self _expirationDatePresent];
    
    if (!expirationDatePresent) {
        
        NSLog(@"No expiration date present = no active subscription");
        
        hasActiveSubscription = NO;
    }
    else {
    
        BOOL subscriptionExpired = [self _subscriptionExpired];
        
        hasActiveSubscription = !subscriptionExpired;
        
        BOOL needsUpdate = subscriptionExpired;
        
        if (needsUpdate) {
            
            [self _requestUpdateExpirationDate];
        }
    }
    
    return hasActiveSubscription;
}


- (BOOL) _expirationDatePresent {

    NSDate* expirationDate = [self _currentExpirationDate];

    return expirationDate != nil;
}


- (NSDate*) _currentExpirationDate {
    
    NSDate* expirationDate = [_settingsManager valueForKey:SETTINGS_MANAGER_EXPIRATION_DATE_KEY];
    
    return expirationDate;
}


//- (BOOL) _needsUpdateExpirationDate {
//    
//    if (![self _expirationDatePresent]) {
//        
//        NSLog(@"no expiration date set -> needs no update for expiration date");
//        
//        return NO;
//    }
//    
//    
////    NSDate* nextUpdateDate = [_settingsManager valueForKey:SETTINGS_MANAGER_NEXT_UPDATE_DATE_KEY];
//    NSDate* timeNow = [NSDate date];
//    NSDate* expirationDate = [self _currentExpirationDate];
//    NSTimeInterval interval = [expirationDate timeIntervalSinceDate:timeNow];
//    float intervalInMinutes = interval / 60;
//    
//    BOOL needsUpdate;
//    
//    if (interval < 0) {
//        
//        NSLog(@"Expiration date needs updating (%0.1f minutes)", intervalInMinutes);
//        
//        needsUpdate = YES;
//    }
//    else {
//        
//        needsUpdate = NO;
//    }
//    
//    return needsUpdate;
//}


- (BOOL) _subscriptionExpired {
    
    
    NSDate* timeNow = [NSDate date];
    NSDate* expirationDate = [self _currentExpirationDate];
    NSTimeInterval interval = [expirationDate timeIntervalSinceDate:timeNow];
    float intervalInMinutes = interval / 60;
    
    BOOL subscriptionExpired;
    
    if (interval > 0) {
        
        NSLog(@"Subscription is valid (%0.f minutes)", intervalInMinutes);
        
        subscriptionExpired = NO;
    }
    else {
        
        NSLog(@"Subscription has expired (%0.f minutes)", intervalInMinutes);
        
        subscriptionExpired = YES;
    }
    
    return subscriptionExpired;
}



#pragma mark - Purchasing Products

- (void) _initiatePurchaseOfProduct:(SKProduct*) product {
    
    if ([SKPaymentQueue canMakePayments]) {

        _productToPurchase = product;
        _purchasing = YES;

        SKPayment* payment = [SKPayment paymentWithProduct:product];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else {
        
        [self _handleCantMakePayments];
    }
}



#pragma mark - Cant Make Payments

- (void) _handleCantMakePayments {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Hinweis" message:@"Es können keine Transaktionen getätigt werden. Bitte überprüfen Sie ihre Einstellungen." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    [alertView show];
}



#pragma mark - SKProductsRequestDelegate

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSArray* products = response.products;
    NSArray* invalid = response.invalidProductIdentifiers;
    
    for (SKProduct* product in products) {
        
        NSLog(@"---------------------");
        NSLog(@"localizedDescription: %@", product.localizedDescription);
        NSLog(@"localizedTitle: %@", product.localizedTitle);
        NSLog(@"price: %@", product.price);
        NSLog(@"priceLocale: %@", product.priceLocale);
        NSLog(@"productIdentifier: %@", product.productIdentifier);
        NSLog(@"downloadable: %d", product.downloadable);
    }
    
    self.products = products;
    
    [self _reportLoadedProducts];
}




#pragma mark - SKPaymentTransactionObserver

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction* transaction in transactions) {
        
        [self _handleUpdateTransaction:transaction];
    }
    
//    // remove observer if no more pending transactions
//    
//    BOOL hasPendingTransactions = NO;
//    
//    NSArray* transactionsInQueue = [SKPaymentQueue defaultQueue].transactions;
//    
//    NSLog(@"%d transactions in queue", transactionsInQueue.count);
//    
//    for (SKPaymentTransaction* transaction in transactionsInQueue) {
//
//        NSLog(@"transaction: %@  --- state: %ld", transaction.transactionIdentifier, transaction.transactionState);
//        
//        if (transaction.transactionState == SKPaymentTransactionStatePurchasing ||
//            transaction.transactionState == SKPaymentTransactionStateDeferred) {
//        
//            NSLog(@"has pending transactions");
//            
//            hasPendingTransactions = YES;
//            break;
//        }
//    }
//    
//    if (!hasPendingTransactions) {
//        
//        NSLog(@"no more pending transactions -> removing transaction observer");
//        
//    }
}


- (void) _handleUpdateTransaction:(SKPaymentTransaction*) transaction {
    
    if ([self _isOldTransaction:transaction] && transaction.transactionState != SKPaymentTransactionStateRestored) {  // if transaction is old but is NOT a restored transaction
        
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
//        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
        
        NSLog(@"finished old transaction: %@ (date: %@, state: %ld)", transaction.transactionIdentifier, transaction.transactionDate, transaction.transactionState);
        
        NSLog(@"old transaction state: %d", transaction.transactionState);
        
        return;
    }
    
    
    switch (transaction.transactionState) {
            
        case SKPaymentTransactionStatePurchasing: {
            
            NSLog(@"Purchasing");
            
            [self _handleDidBeginPurchasingProduct:_productToPurchase];
        }
            break;
            
            
        case SKPaymentTransactionStatePurchased: {
            
            NSLog(@"Purchased");
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];  // must be called here
            
//            [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
            
            _purchasing = NO;
            
            [self _handleProductSuccessfullyPurchased:_productToPurchase];
        }
            break;
            
            
        case SKPaymentTransactionStateFailed: {  // called when purchase is cancelled by user
            
            NSLog(@"Purchase failed");
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];  // must be called here
            
//            [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
            
            _purchasing = NO;
            
            [self _handlePurchaseFailedForProduct:_productToPurchase];
            
        }
            break;
            
        case SKPaymentTransactionStateRestored: {
            
            NSLog(@"Purchase restored (transaction: %@)", transaction);
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
            
            break;
            
            
        case SKPaymentTransactionStateDeferred: {
            
            NSLog(@"Purchase deferred");
        }
            break;
            
            
            
        default:
            break;
    }
}


- (void) paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction* transaction in transactions) {
        
        NSLog(@"removed transaction: %@ (date: %@, state: %ld)", transaction.transactionIdentifier, transaction.transactionDate, transaction.transactionState);
    }
}



- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    NSLog(@"Restore products complete.");
    
    [self _handleRestoreCompletedSuccessfully];
}


- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
    NSLog(@"Restore products failed!");
    
    [self _handleRestoreFailedWithError:error];
}






#pragma mark - Handle Events

- (void) _handleDidBeginPurchasingProduct:(SKProduct*) product {
    
    [self _reportDidBeginPurchasingProduct:product];
}

- (void) _handleProductSuccessfullyPurchased:(SKProduct*) product {
    
    [self _reportProductPurchased:product];
    
    [self _requestUpdateExpirationDate];
}


- (void) _handlePurchaseFailedForProduct:(SKProduct*) product {
    
    [self _reportPurchaseFailedForProduct:product];
    
//    [self _requestUpdateExpirationDate];  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! !!!!!!!!! !!!!!!!! !!!!!!!!!!

}


- (void) _handleRestoreCompletedSuccessfully {
    
    [self _reportRestoreCompletedSuccessfully];
}


- (void) _handleRestoreFailedWithError:(NSError*) error {
    
    [self _reportRestoreFailedWithError:error];
}





#pragma mark - Expiration Date

// should only be called 1) after a purchase and 2) after restore

- (void) _requestUpdateExpirationDate {
    
    if (_requestingUpdateExpirationDate) return;
    
    
    NSLog(@"requesting update expiration date (long check = receipt validation with iTunes server)");
    
    _requestingUpdateExpirationDate = YES;
    
    [[SubscriptionReceiptManager instance] requestExpirationDateWithCompletionBlock:^(NSDate *expirationDate, NSString* productID, NSError *error) {
    
        _requestingUpdateExpirationDate = NO;
        
        if (error) {
            
            [self _handleSubscriptionReceiptManagerError:error];
        }
        else if (expirationDate) {
            
            [self _updateExpirationDate:expirationDate productID:productID];
        }
    }];
}


- (void) _updateExpirationDate:(NSDate*) date productID:(NSString*) productID {

    [_settingsManager setValue:date forKey:SETTINGS_MANAGER_EXPIRATION_DATE_KEY];  // very important!
    [_settingsManager setValue:productID forKey:SETTINGS_MANAGER_PRODUCT_ID_KEY];
    
//    NSTimeInterval nextUpdateInterval = EXPIRATION_DATE_UPDATE_INTERVAL * 60;
//    NSDate* nextUpdateDate = [[NSDate date] dateByAddingTimeInterval:nextUpdateInterval];
    
//    [_settingsManager setValue:nextUpdateDate forKey:SETTINGS_MANAGER_NEXT_UPDATE_DATE_KEY];
    
    NSLog(@"Updated expiration date (%@)", date);
//    NSLog(@"Next update date: %@ (in %0.f minutes)", nextUpdateDate, nextUpdateInterval / 60);
    
    [self _updateHasActiveSubscription];
    
//    [self _reportSubscriptionStatusUpdated];
}




#pragma mark - Check Internet Connection

- (BOOL) _canConnectToInternetSilent:(BOOL) silent {

    BOOL canConnectToInternet = [[ReachabilityManager instance] canConnectToInternet];
    
    
    // error message if needed
    
    if (!canConnectToInternet && !silent) {
        
        [self _handleNoInternet];
    }
    
    
    return canConnectToInternet;
}




#pragma mark - Utility

- (BOOL) _isOldTransaction:(SKPaymentTransaction*) transaction {
    
    NSDate* timeNow = [NSDate date];
    NSDate* transactionDate = transaction.transactionDate;
    NSTimeInterval interval = [timeNow timeIntervalSinceDate:transactionDate];
    float intervalInMinutes = interval / 60;
    
    return intervalInMinutes > MINUTES_BEFORE_TRANSACTION_IS_OLD;
}



#pragma mark - Observers

- (void) addObserver:(id<SubscriptionManagerObserver>)observer {
    
    NSValue* value = [NSValue valueWithNonretainedObject:observer];
    
    
    if ([self.observers containsObject:value]) return;
    
    
    if (![self.observers containsObject:value]) {
        
        [self.observers addObject:value];
    }
    
    [self _debug_printObserverCount];
}


- (void) removeObserver:(id<SubscriptionManagerObserver>)observer {
    
    [self.observers removeObject:[NSValue valueWithNonretainedObject:observer]];
    
    [self _debug_printObserverCount];
}


- (void) _debug_printObserverCount {
    
    NSLog(@"SubscriptionManager - observer count: %ld", _observers.count);
}


- (void) _reportLoadedProducts {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(subscriptionManagerDidLoadProducts:)]) {
            
            [observer subscriptionManagerDidLoadProducts:self.products];
        }
    }
}


- (void) _reportDidBeginPurchasingProduct:(SKProduct*) product {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(subscriptionManagerDidBeginPurchasingProduct:)]) {
            
            [observer subscriptionManagerDidBeginPurchasingProduct:product];
        }
    }
}


- (void) _reportProductPurchased:(SKProduct*) product {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(subscriptionManagerDidFinishPurchasingProduct:)]) {
            
            [observer subscriptionManagerDidFinishPurchasingProduct:product];
        }
    }
}


- (void) _reportPurchaseFailedForProduct:(SKProduct*) product {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(subscriptionManagerPurchaseFailedForProduct:)]) {
            
            [observer subscriptionManagerPurchaseFailedForProduct:product];
        }
    }
}


- (void) _reportSubscriptionStatusUpdated { // shud only be called from one place (needs condition)
    
    NSLog(@"SubscriptionManager - reportSubscriptionStatusUpdated");
    
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(subscriptionManagerDidUpdateSubscriptionStatus)]) {
            
            [observer subscriptionManagerDidUpdateSubscriptionStatus];
        }
    }
}


- (void) _reportSubscriptionStatusDetermined {  // needed, i.e. for ActiveSubscriptionsViewController, !!! also gets called when the small check is performed, so might deliver a different status shortly after after the medium check
    
    NSLog(@"SubscriptionManager - reportSubscriptionStatusDetermined");
    
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(subscriptionManagerDidDetermineSubscriptionStatus)]) {
            
            [observer subscriptionManagerDidDetermineSubscriptionStatus];
        }
    }
    
}


- (void) _reportRestoreCompletedSuccessfully {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(subscriptionManagerRestoreCompletedSuccessfully)]) {
            
            [observer subscriptionManagerRestoreCompletedSuccessfully];
        }
    }
}


- (void) _reportRestoreFailedWithError:(NSError*) error {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(subscriptionManagerRestoreFailedWithError:)]) {
            
            [observer subscriptionManagerRestoreFailedWithError:error];
        }
    }
}



- (void) _reportError:(NSError*) error {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([observer respondsToSelector:@selector(subscriptionManagerDidReportError:)]) {
            
            [observer subscriptionManagerDidReportError:error];
        }
    }
}




#pragma mark - Error handling

- (void) _handleSubscriptionReceiptManagerError:(NSError*) error {
    
    [self _reportError:error];  // pass thru error from SubscriptionReceiptManager
}


- (void) _handleNoInternet {
    
    NSError* error = [self _errorWithCode:kSubscriptionManagerErrorNoInternet];
    
    [self _reportError:error];
}


- (NSError*) _errorWithCode:(NSInteger) code {
    
    NSError* error = [NSError errorWithDomain:kSubscriptionManagerErrorDomain
                                         code:code
                                     userInfo:nil];
    
    return error;
}



#pragma mark - Dealloc

- (void) dealloc {
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];

}


@end
