//
//  RestoreProductsViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "SubscriptionManager.h"
#import "CustomAlertViewController.h"



@interface RestoreProductsHandler : NSObject <SubscriptionManagerObserver> {
    
    CustomAlertViewController* _controller;
    
    __weak UIViewController* _weakParentController;  // do not retain or else retain cycle
    
    BOOL _restoreCompleted;
}

- (void) presentPopupWithParentViewController:(UIViewController*) parentController;

@end
