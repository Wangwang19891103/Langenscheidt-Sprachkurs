//
//  SubscriptionReceiptManager.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;



extern NSString* const kSubscriptionReceiptManagerErrorDomain;

extern NSInteger const kSubscriptionReceiptManagerErrorNoInternet;

extern NSInteger const kSubscriptionReceiptManagerErrorJSONFromValidationResponseData;

extern NSInteger const kSubscriptionReceiptManagerErrorValidationRequestURLSessionFailed;

extern NSInteger const kSubscriptionReceiptManagerErrorNoReceiptAfterRefreshRequest;

extern NSInteger const kSubscriptionReceiptManagerErrorNoLatestReceiptInfo;

extern NSInteger const kSubscriptionReceiptManagerErrorNoExpirationDate;

extern NSInteger const kSubscriptionReceiptManagerErrorExpirationDateFormatError;



//typedef NS_ENUM(NSInteger, SubscriptionReceiptManagerError) {
//    ValidationResponseDataJSONError = 0,
//    
//    FailedToRefreshReceiptError = 1
//    
//};


@interface SubscriptionReceiptManager : NSObject <NSURLSessionDelegate,
NSURLSessionDataDelegate, NSURLSessionTaskDelegate, SKRequestDelegate> {
    
    void(^_requestCompletionBlock)(NSDate*, NSString*, NSError*);
    
    BOOL _refreshingReceipt;
    
}

+ (instancetype) instance;


- (void) requestExpirationDateWithCompletionBlock:(void(^)(NSDate* expirationDate, NSString* productID, NSError* error)) completionBlock;

@end
