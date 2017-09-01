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



#define PRODUCT_DICTS_FILE                          @"products.plist"

#define MINUTES_BEFORE_TRANSACTION_IS_OLD           5.0  // minutes

#define SETTINGS_MANAGER_INSTANCE_NAME              @"subscription"
#define SETTINGS_MANAGER_EXPIRATION_DATE_KEY        @"expiration-date"
#define SETTINGS_MANAGER_PRODUCT_ID_KEY             @"product-id"

#define MINIMUM_INTERVAL_BETWEEN_VALIDATIONS        1.0 // minutes



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
    _subscriptionActive = NO;
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    
//    [self _requestUpdateExpirationDate]; // for testing
    
    return self;
}












#pragma mark - Query / Update active subscription


/** This method returns the result of a recent update check, but doesnt perform any checks itself. This method is very lightweight */

- (BOOL) hasActiveSubscription {
    
    NSLog(@"subscriptionActive: %d", _subscriptionActive);
    
    return _subscriptionActive;
    
}


/** This method will perform a check on the most recent expiration date. This method doesnt return the result of the check right away but instead will report the result in 1 or 2 steps to its observers (if present, the 2nd will be asynchronously) */

- (void) requestUpdateHasActiveSubscriptionForceValidation:(BOOL) forceValidation {
    
    [self _updateHasActiveSubscriptionAllowValidation:YES forceValidation:forceValidation];
    
}


- (void) _updateHasActiveSubscriptionAllowValidation:(BOOL) allowValidation forceValidation:(BOOL) forceValidation {
    
    NSLog(@"SubscriptionManager - _updateHasActiveSubscription (allowValidation: %d)", allowValidation);

    
    // 1. Check if expiration date is currently known to the app (checking user settings, not checking the receipt)
    
    BOOL expirationDatePresent = [self _expirationDatePresent];
    
    if (expirationDatePresent) {  // is present
        
        NSLog(@"... expiration date is present");
        
        
        // 1.1. Check the expiration date for validity (compare to NOW)
        
        NSDate* currentExpirationDate = [self _currentExpirationDate];
        BOOL expirationDateValid = [self _expirationDateValid:currentExpirationDate];
        
        if (expirationDateValid) {  // is valid
            
            NSLog(@"... expiration date is valid");
            
            
            // 1.1.1. This means, the status for active subscription will be set to YES (valid)
            
            _subscriptionActive = YES;
            
            
            // Report to observers that status has been updated
            
            [self _reportSubscriptionStatusUpdatedVaidating:NO];
            
        }
        else {  // is expired
            
            NSLog(@"... expiration date is expired");
            
            
            // 1.1.2. This means, there was an active subscription at some point, hence the known expiration date. First, the observers will be informed that there is currently no active subscription found but that there is a validation process on the way. Second, when the validation process is complete, the observers will be informed of that result.
            
            _subscriptionActive = NO;
            
            
            // If allowed, initiate receipt validation to retrieve a possibly updated expiration date (subscription has been renewed)
            
            // This is normally allowed, but not when this method call is coming from a validation callback itself
            
            BOOL validationAvailable = NO;
            
            if (forceValidation) {
                
                NSLog(@"... forcing validation");
            }
            else if (allowValidation) {
            
                validationAvailable = [self _validationAvailable];
            }
            
            BOOL shouldValidate = forceValidation || (allowValidation && validationAvailable);
            
            if (shouldValidate) {
                
                NSLog(@"... requesting receipt validation");
                
                [self _requestUpdateExpirationDate];
            }
            
            
            // Report to observers that status has been updated, but also that validation is on the way (second update coming up soon) if it was allowed.
            
            BOOL validating = shouldValidate;
            
            [self _reportSubscriptionStatusUpdatedVaidating:validating];
        }
        
    }
    else {  // is not present
        
        NSLog(@"... no expiration date present");
        
        
        // 1.2. This means, the app has no knowledge about any subscription ever existing. Hence, the receipt will not be checked, since there is no reason. To let the app know (user settings) that there is a subscription, a purchase or a product restore has to be made, which will create the expiration date in the user settings. Result is: no subscription
        
        // Important: This subtree of the method will not initiate a receipt validation, because this check cannot be made too frequently. Instead it will depend on the expiration date being created through a purchase or product restore.
        
        _subscriptionActive = NO;
        
        
        // Report to observers that status has been updated
        
        [self _reportSubscriptionStatusUpdatedVaidating:NO];
        
    }
    
}


- (NSString*) activeProductIdentifier {
    
    return [_settingsManager valueForKey:SETTINGS_MANAGER_PRODUCT_ID_KEY];
    
}


/** This method will return the currently known expiration date stored in the user settings. It will not perform an update check. (Lightweight) */

- (NSDate*) currentExpirationDate {
    
    return [_settingsManager valueForKey:SETTINGS_MANAGER_EXPIRATION_DATE_KEY];
    
}



/** This method checks if the expiration date is valid or expired (compare to NOW) */

- (BOOL) _expirationDateValid:(NSDate*) expirationDate {
    
    NSDate* timeNow = [NSDate date];
    NSTimeInterval interval = [expirationDate timeIntervalSinceDate:timeNow];
    float intervalInMinutes = interval / 60;
    
    BOOL isValid;
    
    if (interval > 0) {
        
        NSLog(@"Subscription is valid (%0.f minutes)", intervalInMinutes);
        
        isValid = YES;
    }
    else {
        
        NSLog(@"Subscription has expired (%0.f minutes)", intervalInMinutes);
        
        isValid = NO;
    }
    
    return isValid;
}


/** This method checks if an expiration date is known to the app, i.e. stored in the user settings. */

- (BOOL) _expirationDatePresent {
    
    NSDate* expirationDate = [self _currentExpirationDate];
    
    return expirationDate != nil;
}


/** This method returns the currently known expiration date, stored in the user settings. */

- (NSDate*) _currentExpirationDate {
    
    NSDate* expirationDate = [_settingsManager valueForKey:SETTINGS_MANAGER_EXPIRATION_DATE_KEY];
    
    return expirationDate;
}


/** This method returns whether a validation attempt is available (minimum interval since last attempt has expired) */

- (BOOL) _validationAvailable {
    
    BOOL validationAvailable = NO;
    
    // check if there was a previous attempt
    
    BOOL lastValidationAttemptPresent = (_lastValidationAttempt != nil);
    
    if (lastValidationAttemptPresent) {
        
        // Check if the interval between last attempt has expired
        
        NSDate* timeNow = [NSDate date];
        NSTimeInterval interval = [timeNow timeIntervalSinceDate:_lastValidationAttempt];
        float intervalInMinutes = interval / 60;
        
        NSLog(@"Time since last validation: %0.2f minutes", intervalInMinutes);
        
        if (intervalInMinutes >= MINIMUM_INTERVAL_BETWEEN_VALIDATIONS) {
            
            // Minimum interval has expired -> new validation is available
            
            validationAvailable = YES;
        }
        else {

            // Minimum interval has not expired -> no new validation is available
            
            validationAvailable = NO;
        }
    }
    else {
        
        // There was no previous attempt, so there is one available now
        
        validationAvailable = YES;
    }
    
    NSLog(@"... validation available: %@", validationAvailable ? @"yes" : @"no");
    
    return validationAvailable;
}









#pragma mark - Update Expiration Date / Receipt Validation

/** This method will tell the SubscriptionReceiptManager to request a receipt validation in order to retrieve the most recent expiration date. The request may fail with an error. */

- (void) _requestUpdateExpirationDate {
    
    if (_requestingUpdateExpirationDate) return;
    
    
    BOOL canConnectToInternet = [self _canConnectToInternetSilent:NO];
    
    if (!canConnectToInternet) return;
    
    // ------
    
    
    NSLog(@"requesting update expiration date (long check = receipt validation with iTunes server)");
    
    _requestingUpdateExpirationDate = YES;
    _lastValidationAttempt = [NSDate date]; // now
    
    [[SubscriptionReceiptManager instance] requestExpirationDateWithCompletionBlock:^(NSDate *expirationDate, NSString* productID, NSError *error) {
        
        _requestingUpdateExpirationDate = NO;
        
        if (error) {
            
            [self _handleSubscriptionReceiptManagerError:error];
        }
        else if (expirationDate) {
            
            NSLog(@"RECEIPT SUCCESSFULLY VALIDATED");
            
            [self _updateExpirationDate:expirationDate productID:productID];
        }
    }];
}


/** This method will save the newly retrieved expiration date (from receipt validation) and the product identifier to the user settings and then update the subscription status. */

- (void) _updateExpirationDate:(NSDate*) date productID:(NSString*) productID {
    
    [_settingsManager setValue:date forKey:SETTINGS_MANAGER_EXPIRATION_DATE_KEY];  // very important!
    [_settingsManager setValue:productID forKey:SETTINGS_MANAGER_PRODUCT_ID_KEY];
    
    NSLog(@"Updated expiration date (%@)", date);
    
    
    // perform a subscription status update, but do not allow another receipt validation incase the newly retrieved expiration date is expired
    
    [self _updateHasActiveSubscriptionAllowValidation:NO forceValidation:NO];
}













#pragma mark - Load / purchase products

/** This method will try to connect to iTunes and retrieve information on the products. */

- (void) loadProducts {
    
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


- (void) purchaseProduct:(SKProduct *)product {
    
    if (_purchasing) {
        
        NSLog(@"already purchasing");
        
        return;
    }
    
    
    BOOL canConnectToInternet = [self _canConnectToInternetSilent:NO];
    
    if (!canConnectToInternet) return;
    
    
    [self _initiatePurchaseOfProduct:product];
}


















#pragma mark - Product Information

- (NSString*) titleForProduct:(SKProduct*) product {
    
    return [self titleForProductID:product.productIdentifier];
}


- (NSString*) titleForProductID:(NSString*) productID {
    
    NSString* title = nil;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID2 = productDict[@"productID"];
        
        if ([productID2 isEqualToString:productID]) {
            
            title = productDict[@"title"];
            
            break;
        }
    }
    
    return title;
}


- (NSString*) longTitleForProductID:(NSString*) productID {
    
    NSString* title = nil;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID2 = productDict[@"productID"];
        
        if ([productID2 isEqualToString:productID]) {
            
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


- (NSString*) description2ForProduct:(SKProduct*) product {
    
    NSString* description2 = nil;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID = productDict[@"productID"];
        
        if ([productID isEqualToString:product.productIdentifier]) {
            
            description2 = productDict[@"description"];
            
            break;
        }
    }
    
    return description2;
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


- (BOOL) isEarlyBirdForProduct:(SKProduct*) product {
    
    BOOL isTopPrice = NO;
    
    for (NSDictionary* productDict in _productDicts) {
        
        NSString* productID = productDict[@"productID"];
        
        if ([productID isEqualToString:product.productIdentifier]) {
            
            isTopPrice = [productDict[@"isEarlyBird"] boolValue];
            
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


- (void) removeRestoreHandler {
    
    _restoreHandler = nil;
}


/** This method will perform a restore request. After a successful restore the expiration date will be updated and observers will be informed. */

- (void) requestRestoreProducts {
    
    // this must be implemented safely!
    
//    BOOL canConnectToInternet = [self _canConnectToInternetSilent:NO];
//    
//    if (!canConnectToInternet) return;
    
    
    [self _restoreProducts];
    
}


- (void) _restoreProducts {
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}


- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    NSLog(@"Restore products complete.");
    
    [self _handleRestoreCompletedSuccessfully];
}


- (void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
    NSLog(@"Restore products failed!");
    
    [self _handleRestoreFailedWithError:error];
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
    
}


- (void) _handleUpdateTransaction:(SKPaymentTransaction*) transaction {
    
    if ([self _isOldTransaction:transaction] && transaction.transactionState != SKPaymentTransactionStateRestored) {  // if transaction is old but is NOT a restored transaction
        
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
        NSLog(@"finished old transaction: %@ (date: %@, state: %ld)", transaction.transactionIdentifier, transaction.transactionDate, transaction.transactionState);
        
        NSLog(@"old transaction state: %ld", transaction.transactionState);
        
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
            
            _purchasing = NO;
            
            [self _handleProductSuccessfullyPurchased:_productToPurchase];
        }
            break;
            
            
        case SKPaymentTransactionStateFailed: {  // called when purchase is cancelled by user
            
            NSLog(@"Purchase failed");
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];  // must be called here
            
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
    
    
    // request validation to retrieve the expiration date and update the UI
    
    [self _requestUpdateExpirationDate];
}


- (void) _handleRestoreFailedWithError:(NSError*) error {
    
    [self _reportRestoreFailedWithError:error];
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
        
        if ([self _observerShouldHandleSubscriptionManagerEvents:observer]) {
        
            if ([observer respondsToSelector:@selector(subscriptionManagerDidLoadProducts:)]) {
                
                [observer subscriptionManagerDidLoadProducts:self.products];
            }
        }
    }
}


- (void) _reportDidBeginPurchasingProduct:(SKProduct*) product {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([self _observerShouldHandleSubscriptionManagerEvents:observer]) {
            
            if ([observer respondsToSelector:@selector(subscriptionManagerDidBeginPurchasingProduct:)]) {
                
                [observer subscriptionManagerDidBeginPurchasingProduct:product];
            }
        }
    }
}


- (void) _reportProductPurchased:(SKProduct*) product {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([self _observerShouldHandleSubscriptionManagerEvents:observer]) {
            
            if ([observer respondsToSelector:@selector(subscriptionManagerDidFinishPurchasingProduct:)]) {
                
                [observer subscriptionManagerDidFinishPurchasingProduct:product];
            }
        }
    }
}


- (void) _reportPurchaseFailedForProduct:(SKProduct*) product {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([self _observerShouldHandleSubscriptionManagerEvents:observer]) {
            
            if ([observer respondsToSelector:@selector(subscriptionManagerPurchaseFailedForProduct:)]) {
                
                [observer subscriptionManagerPurchaseFailedForProduct:product];
            }
        }
    }
}


//- (void) _reportSubscriptionStatusUpdated { // shud only be called from one place (needs condition)
//    
//    NSLog(@"SubscriptionManager - reportSubscriptionStatusUpdated");
//    
//    
//    for (NSValue* value in self.observers) {
//        
//        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
//        
//        if ([observer respondsToSelector:@selector(subscriptionManagerDidUpdateSubscriptionStatus)]) {
//            
//            [observer subscriptionManagerDidUpdateSubscriptionStatus];
//        }
//    }
//}


//- (void) _reportSubscriptionStatusDetermined {  // needed, i.e. for ActiveSubscriptionsViewController, !!! also gets called when the small check is performed, so might deliver a different status shortly after after the medium check
//    
//    NSLog(@"SubscriptionManager - reportSubscriptionStatusDetermined");
//    
//    
//    for (NSValue* value in self.observers) {
//        
//        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
//        
//        if ([observer respondsToSelector:@selector(subscriptionManagerDidDetermineSubscriptionStatus)]) {
//            
//            [observer subscriptionManagerDidDetermineSubscriptionStatus];
//        }
//    }
//    
//}


- (void) _reportRestoreCompletedSuccessfully {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([self _observerShouldHandleSubscriptionManagerEvents:observer]) {
            
            if ([observer respondsToSelector:@selector(subscriptionManagerRestoreCompletedSuccessfully)]) {
                
                [observer subscriptionManagerRestoreCompletedSuccessfully];
            }
        }
    }
}


- (void) _reportRestoreFailedWithError:(NSError*) error {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([self _observerShouldHandleSubscriptionManagerEvents:observer]) {
            
            if ([observer respondsToSelector:@selector(subscriptionManagerRestoreFailedWithError:)]) {
                
                [observer subscriptionManagerRestoreFailedWithError:error];
            }
        }
    }
}

/** This method will report to all observers that the subscription status has been update (per request). Validating is YES if the receipt is currently validated, which will lead to a 2nd update report in the near future. */

- (void) _reportSubscriptionStatusUpdatedVaidating:(BOOL) validating {
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([self _observerShouldHandleSubscriptionManagerEvents:observer]) {
            
            if ([observer respondsToSelector:@selector(subscriptionManagerDidUpdateSubscriptionStatusValidating:)]) {
                
                [observer subscriptionManagerDidUpdateSubscriptionStatusValidating:validating];
            }
        }
    }
}



- (void) _reportError:(NSError*) error {

    NSLog(@"SubscriptionManager - wants to report error: %@", error);
    
    for (NSValue* value in self.observers) {
        
        id<SubscriptionManagerObserver> observer = [value nonretainedObjectValue];
        
        if ([self _observerShouldHandleSubscriptionManagerEvents:observer]) {
            
            if ([observer respondsToSelector:@selector(subscriptionManagerDidReportError:)]) {
                
                [observer subscriptionManagerDidReportError:error];
            }
        }
    }
}


- (BOOL) _observerShouldHandleSubscriptionManagerEvents:(id<SubscriptionManagerObserver>) observer {
    
    BOOL shouldHandle = YES;
    
    if ([observer respondsToSelector:@selector(shouldHandleSubscriptionManagerEvents)]) {
        
        shouldHandle = [observer shouldHandleSubscriptionManagerEvents];
    }
    
    return shouldHandle;
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
