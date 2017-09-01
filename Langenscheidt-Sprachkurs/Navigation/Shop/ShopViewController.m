//
//  ShopViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Wang on 19.05.16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "ShopViewController.h"
#import "ShopCell.h"
#import "ShopLoadingCell.h"
#import "ErrorMessageManager.h"
#import "SubscriptionReceiptManager.h"  // for error domain and codes
#import "LTracker.h"


#define HEADER_CELL_HEIGHT              95
#define SHOP_CELL_HEIGHT                140
#define DESC_CELL_HEIGHT                215




@implementation ShopViewController


#pragma mark - Init

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
//    [self _requestProducts];
    
    [[SubscriptionManager instance] addObserver:self];

    _loading = YES;
    
    return self;
}




#pragma mark - View

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
    GATrackingSetScreenName(@"Shop");
    GATrackingSetTrackScreenViews(YES);
    
    
    self.tableView.estimatedRowHeight = 160;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.alwaysBounceVertical = NO;
    
    self.navigationItem.title = @"Freischalten";
    
}


- (void) viewDidAppear:(BOOL)animated {
    
    // will not be called when background/foreground (which is good, to not interupt a purchase)
    
    NSLog(@"ShopViewController - viewDidAppear");
    
    _shouldHandleEvents = YES;
    
    NSLog(@"ShopViewController - shouldHandleEvents = %d", _shouldHandleEvents);
    
    
    [super viewDidAppear:animated];
    
    __weak ShopViewController* weakSelf = self;
    
    
    if (_loading){
     
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf _requestProducts];
        });
    }

}


- (void) viewWillDisappear:(BOOL)animated {
    
    NSLog(@"ShopViewController - viewWillDisappear");

    _shouldHandleEvents = NO;
    
    NSLog(@"ShopViewController - shouldHandleEvents = %d", _shouldHandleEvents);

    
    [super viewWillDisappear:animated];
}



#pragma mark - Populate with Products

- (void) _populate {
    
    _loading = NO;
    
    [self.tableView reloadData];
}



#pragma mark - Request Products

- (void) _requestProducts {
    
    [[SubscriptionManager instance] loadProducts];
}



#pragma mark - TableView Delegate/Datasource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (_loading) return 2;
    else
    
    return _products.count + 1 + 1; // +1 for header cell + 1 for description cell
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {  // header cell
    
        return HEADER_CELL_HEIGHT;
    }
    else if (indexPath.row == 1) {  // shop cell or error cell

        if (_loading) return 135;
        else

        return SHOP_CELL_HEIGHT;
    }
    else {  // if description cell (if no error)
        
        return DESC_CELL_HEIGHT;
    }
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.row == 0) {  // header cell
     
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
        
        return cell;
    }
    else if (indexPath.row == 1) {  // shop cell or error cell

        if (_loading) {
            
            ShopLoadingCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"LoadingCell"];
            return cell;
        }

        ShopCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"ShopCell"];
        
        SKProduct* product = _products[indexPath.row - 1];  // +1 for header cell offset
        
//        cell.monthLabel.text = [self _titleForProduct:product];
        cell.priceLabel.text = [self _priceForProduct:product];
//        cell.descriptionLabel.text = [self _descriptionForProduct:product];
//        cell.isTopseller = [self _isTopSellerForProduct:product];
//        cell.isTopPrice = [self _isTopPriceForProduct:product];
//        cell.isEarlyBird = [self _isEarlyBirdForProduct:product];
        
        __weak ShopViewController* weakself = self;
        
        cell.actionBlock = ^{
          
            [weakself _purchaseProduct:product];
        };
        
        return cell;
    }
    else {  // if description cell (if no error)
        
        UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"DescriptionCell"];
        
        return cell;
    }
}




#pragma mark - Purchase

- (void) _purchaseProduct:(SKProduct*) product {

    [[SubscriptionManager instance] purchaseProduct:product];
}




#pragma mark - Purchase popup


- (void) _showPopup {

    __weak void(^weakPurchaseCompleteBlock)() = _purchaseCompleteBlock;
    __weak ShopViewController* weakself = self;

    
    // purchasing view
    
    _purchasingView = [[CustomAlertMessageView alloc] initWithTitle:@"Abonnement abschließen" message:@"Dein Kauf wird getätigt. Bitte warten..." okButton:NO];
    
    
    
    // purchase finished view
    
    _purchaseFinishedView = [[CustomAlertMessageView alloc] initWithTitle:@"Abonnement erfolgreich abgeschlossen" message:@"Vielen Dank und viel Spaß beim Lernen." okButton:YES];

    _purchaseFinishedView.okayBlock = ^() {
        
        if (weakPurchaseCompleteBlock) {
            
            weakPurchaseCompleteBlock();
        }
        else {
            
            [weakself dismissPopupWithCompletionBlock:nil];
        }
    };

    
    
    // purchase failed view
    
    _purchaseFailedView = [[CustomAlertMessageView alloc] initWithTitle:@"Abonnement-Kauf fehlgeschlagen" message:@"Leider ist ein Fehler beim Kauf auftreten. Möglicherweise hast Du den Kauf frühzeitig abgebrochen." okButton:YES];
    
    _purchaseFailedView.okayBlock = ^() {
    
        [weakself dismissPopupWithCompletionBlock:nil];
    };
    
    
    
    _alertViewController = [[CustomAlertViewController alloc] init];
    _alertViewController.contentViews = @[_purchasingView, _purchaseFinishedView, _purchaseFailedView];
    
    [self presentViewController:_alertViewController animated:YES completion:^{
        
        _presentingPopup = YES;
    }];
}


- (void) _showPurchaseFinishedView {
    
    [_alertViewController showContentView:_purchaseFinishedView animated:YES];
}


- (void) _showPurchaseFailedView {
    
    [_alertViewController showContentView:_purchaseFailedView animated:YES];
}


- (void) dismissPopupWithCompletionBlock:(void (^)())completionBlock {

    NSLog(@"ShopViewController - dismissing popup");
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        _presentingPopup = NO;
        
        if (completionBlock) {
        
            completionBlock();
        }
    }];
}




#pragma mark - SubscriptionManagerObserver

#pragma mark Should handle events

- (BOOL) shouldHandleSubscriptionManagerEvents {

    return _shouldHandleEvents;
}



#pragma mark Load products

- (void) subscriptionManagerDidLoadProducts:(NSArray *)products {
    
    _products = products;

    [self _populate];
}



#pragma mark Purchasing

- (void) subscriptionManagerDidBeginPurchasingProduct:(SKProduct *)product {
    
    [self _handleDidBeginPurchasing];
}


- (void) subscriptionManagerDidFinishPurchasingProduct:(SKProduct *)product {
    
    [self _handleDidPurchaseSuccessfully];
}


- (void) subscriptionManagerPurchaseFailedForProduct:(SKProduct *)product {
    
    [self _handlePurchaseFailed];
}







#pragma mark Handle Errors

//* this should only receive errors not tied to purchasing */

- (void) subscriptionManagerDidReportError:(NSError *)error {
    
    [self _handleError:error];
}




#pragma mark - Error handling

- (void) _handleError:(NSError*) error {
    
    if ([self _shouldReportError:error]) {
        
        [self _reportError:error];
    }
}


- (BOOL) _shouldReportError:(NSError*) error {
    
    NSString* domain = error.domain;
    NSInteger code = error.code;
    
    BOOL shouldReport = NO;
    
    if ([domain isEqualToString:kSubscriptionManagerErrorDomain]) {
        
        if (code == kSubscriptionManagerErrorNoInternet) {
            
            shouldReport = YES;
        }
    }
    else if ([domain isEqualToString:kSubscriptionReceiptManagerErrorDomain]) {

        shouldReport = YES  && _purchaseCompleted;
        
//        if (code == kSubscriptionReceiptManagerErrorNoInternet) {
//            
//            shouldReport = YES;
//        }
//        else if (code == kSubscriptionReceiptManagerErrorJSONFromValidationResponseData) {
//            
//            shouldReport = YES;
//        }
//        else if (code == kSubscriptionReceiptManagerErrorValidationRequestURLSessionFailed) {
//            
//            shouldReport = YES;
//        }
//        else if (code == kSubscriptionReceiptManagerErrorNoReceiptAfterRefreshRequest) {
//            
//            shouldReport = YES;
//        }
    }
    
    return shouldReport;
}


- (void) _reportError:(NSError*) error {

    __weak UIViewController* parentController = (_presentingPopup) ? _alertViewController : self;
//    UIViewController* parentController = (_presentingPopup) ? _alertViewController : self;
    
    [[ErrorMessageManager instance] handleError:error withParentViewController:parentController completionBlock:^{
        
        NSLog(@"dismissing error");
    }];

}






#pragma mark - Handler methods

- (void) _handleDidBeginPurchasing {
    
    _purchaseCompleted = NO;
    
    [self _showPopup];
}


- (void) _handleDidPurchaseSuccessfully {
    
    _purchaseCompleted = YES;
    
    [self _showPurchaseFinishedView];
}


- (void) _handlePurchaseFailed {
    
    [self _showPurchaseFailedView];
}










#pragma mark - Utility

- (NSString*) _titleForProduct:(SKProduct*) product {
    
    return [[SubscriptionManager instance] titleForProduct:product];
}


- (NSString*) _priceForProduct:(SKProduct*) product {
    
    return [[SubscriptionManager instance] priceForProduct:product];
}


- (NSString*) _descriptionForProduct:(SKProduct*) product {

    NSString* priceString = [self _priceForProduct:product];
    
    NSString* description2 = [[SubscriptionManager instance] description2ForProduct:product];
    
    NSString* description = [NSString stringWithFormat:@"%@ / Woche\n%@", priceString, description2];
    
    return description;

}


- (BOOL) _isTopSellerForProduct:(SKProduct*) product {
    
    return [[SubscriptionManager instance] isTopSellerForProduct:product];
}


- (BOOL) _isTopPriceForProduct:(SKProduct*) product {
    
    return [[SubscriptionManager instance] isTopPriceForProduct:product];
}


- (BOOL) _isEarlyBirdForProduct:(SKProduct*) product {
    
    return [[SubscriptionManager instance] isEarlyBirdForProduct:product];
}








- (void) dealloc {
    
    NSLog(@"ShopViewController - dealloc");
    
    [[SubscriptionManager instance] removeObserver:self];
}

@end
