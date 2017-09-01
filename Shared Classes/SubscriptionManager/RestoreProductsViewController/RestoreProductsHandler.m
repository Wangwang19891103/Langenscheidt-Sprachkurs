//
//  RestoreProductsViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "RestoreProductsHandler.h"
#import "CustomAlertMessageView.h"
#import "SubscriptionReceiptManager.h"
#import "ErrorMessageManager.h"


@implementation RestoreProductsHandler


- (id) init {
    
    self = [super init];
    
    [[SubscriptionManager instance] addObserver:self];
    
    return self;
}


- (void) presentPopupWithParentViewController:(UIViewController*) parentController {
    
    _weakParentController = parentController;  // needed for error handling and displaying
    
    __weak UIViewController* weakPresenter = parentController;
    
    
    _controller = [[CustomAlertViewController alloc] init];
    
    // view1
    
    NSString* title1 = @"Käufe wiederherstellen";
    NSString* message1 = @"Deine Käufe werden wiederhergestellt. Bitte warten.";
    
    CustomAlertMessageView* view1 = [[CustomAlertMessageView alloc] initWithTitle:title1 message:message1 okButton:NO];

    
    // view2
    
    NSString* title2 = @"Käufe wiederherstellen";
    NSString* message2 = @"Deine Käufe wurden erfolgreich wiederhergestellt.";
    
    CustomAlertMessageView* view2 = [[CustomAlertMessageView alloc] initWithTitle:title2 message:message2 okButton:YES];
    view2. okayBlock = ^() {
        
        NSLog(@"dismissing..");
        
        [weakPresenter dismissViewControllerAnimated:YES completion:^{
            
            NSLog(@"dismissed.");
        }];
    };

    
    // view3
    
    NSString* title3 = @"Käufe wiederherstellen";
    NSString* message3 = @"Leider ist ein Fehler beim Wiederherstellen Deiner Käufe aufgetreten.";
    
    CustomAlertMessageView* view3 = [[CustomAlertMessageView alloc] initWithTitle:title3 message:message3 okButton:YES];
    view3. okayBlock = ^() {
        
        NSLog(@"dismissing..");
        
        [weakPresenter dismissViewControllerAnimated:YES completion:^{
            
            NSLog(@"dismissed.");
        }];
    };

    
    
    
    _controller.contentViews = @[view1, view2, view3];
    
    [parentController presentViewController:_controller animated:YES completion:^{
        
        NSLog(@"presenting");
    }];
    
    
    // ------------------
    
    [[SubscriptionManager instance] requestRestoreProducts];
}




#pragma mark - SubscriptionManagerObserver

- (void) subscriptionManagerRestoreCompletedSuccessfully {
    
    _restoreCompleted = YES;
    
    [_controller showContentView:_controller.contentViews[1] animated:YES];
}


- (void) subscriptionManagerRestoreFailedWithError:(NSError *)error {
    
    NSLog(@"Error: %@", error);
    
    [_controller showContentView:_controller.contentViews[2] animated:YES];

}


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

        shouldReport = YES  && _restoreCompleted;
        
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
    
    if (_weakParentController) {
    
        BOOL isPresentingPopup = _weakParentController.presentedViewController != nil;
        UIViewController* presenter = isPresentingPopup ? _weakParentController.presentedViewController : _weakParentController;
        
        [[ErrorMessageManager instance] handleError:error withParentViewController:presenter completionBlock:^{
            
            NSLog(@"dismissing error");
            
            _restoreCompleted = NO;  // reset so it doesnt handle any other errors thrown
            
            
        }];
    }
}









#pragma mark - Dealloc 

- (void) dealloc {
    
    NSLog(@"RestoreProductsHandler - dealloc");
    
    [[SubscriptionManager instance] removeObserver:self];
}




@end
