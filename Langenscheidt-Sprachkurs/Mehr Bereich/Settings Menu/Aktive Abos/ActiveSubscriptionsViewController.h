//
//  ActiveSubscriptionsViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 03.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "SubscriptionManager.h"


@interface ActiveSubscriptionsViewController : UITableViewController <SubscriptionManagerObserver> {
    
    BOOL _hasActiveSubscription;
    NSString* _productID;
    NSString* _expirationDate;
    
    BOOL _loading;
    BOOL _hasError;
    
    BOOL _shouldHandleEvents;

}

@end
