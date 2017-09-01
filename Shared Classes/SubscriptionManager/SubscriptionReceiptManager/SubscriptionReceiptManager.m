//
//  SubscriptionReceiptManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "SubscriptionReceiptManager.h"
#import "SettingsManager.h"


#define VALIDATION_URL_SANDBOX              @"https://sandbox.itunes.apple.com/verifyReceipt"
#define VALIDATION_URL_PRODUCTION           @"https://buy.itunes.apple.com/verifyReceipt"

#define VALIDATION_URL      VALIDATION_URL_SANDBOX

#define SHARED_SECRET       @"c27d7d13955c45edb3f212e3ad772711"



//#define SIMULATE_ERROR_NO_INTERNET
//#define SIMULATE_ERROR_JSON_ERROR
//#define SIMULATE_ERROR_URL_SESSION  // how to simulate?
//#define SIMULATE_ERROR_NO_RECEIPT








NSString* const kSubscriptionReceiptManagerErrorDomain = @"SubscriptionReceiptManagerErrorDomain";


NSInteger const kSubscriptionReceiptManagerErrorNoInternet = 301;
NSInteger const kSubscriptionReceiptManagerErrorJSONFromValidationResponseData = 302;
NSInteger const kSubscriptionReceiptManagerErrorValidationRequestURLSessionFailed = 303;
NSInteger const kSubscriptionReceiptManagerErrorNoReceiptAfterRefreshRequest = 304;
NSInteger const kSubscriptionReceiptManagerErrorNoLatestReceiptInfo = 305;
NSInteger const kSubscriptionReceiptManagerErrorNoExpirationDate = 306;
NSInteger const kSubscriptionReceiptManagerErrorExpirationDateFormatError = 307;



@implementation SubscriptionReceiptManager


#pragma mark - Init

+ (instancetype) instance {
    
    static SubscriptionReceiptManager* __instance = nil;
    
    @synchronized (self) {
        
        if (!__instance) {
            
            __instance = [[SubscriptionReceiptManager alloc] init];
        }
        
        return __instance;
    }
}


- (id) init {
    
    self = [super init];
    
    
    return self;
}




#pragma mark - Request Expiration Date

- (void) requestExpirationDateWithCompletionBlock:(void (^)(NSDate *, NSString*, NSError *))completionBlock {
    
    _requestCompletionBlock = completionBlock;
    
    [self _validateAndParseReceipt];
}




#pragma mark - Receipt Validation / Parsing

- (void) _validateAndParseReceipt {
    
    if ([self _receiptExists]) {
        
        [self _sendReceiptValidationRequest];
    }
    else {
        
        [self _sendReceiptRefreshRequest];
    }
}


- (void) _sendReceiptValidationRequest {
 
    NSData* receiptData = [self _receiptData];
    
    if (!receiptData) return;
    
    
    NSString* receiptString = [receiptData base64EncodedStringWithOptions:0];
    
    if (!receiptString) return;
    
    
    NSMutableDictionary* receiptDict = [NSMutableDictionary dictionary];
    
    [receiptDict setObject:receiptString forKey:@"receipt-data"];
    [receiptDict setObject:SHARED_SECRET forKey:@"password"];
 
    NSData* requestData = [NSJSONSerialization dataWithJSONObject:receiptDict options:0 error:nil];
    
    if (!requestData) return;
    
    
    NSURL* validationURL = [NSURL URLWithString:VALIDATION_URL];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:validationURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = requestData;
    
//    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
//                                                          delegate:self
//                                                     delegateQueue:nil];
//    
//    // !!!!!!! invalidateAndCancel finishTaskAndInvalidate
//    
//    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request];
//    [dataTask resume];
    
    
    
    
    
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
     
        [self _handleSessionResponseWithData:data response:response error:error];
    }];
    
    [dataTask resume];
}



#pragma mark - Receipt Refresh Request

- (void) _sendReceiptRefreshRequest {
    
    if (_refreshingReceipt) return;
    
    
    _refreshingReceipt = YES;
    
    SKReceiptRefreshRequest* request = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:nil];
    request.delegate = self;
    [request start];
}




//#pragma mark - NSURLSessionDelegate

//- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
//    
//    completionHandler(NSURLSessionResponseAllow);
//}


//- (void) URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
- (void) _handleSessionResponseWithData:(NSData*) data response:(NSURLResponse*) response error:(NSError*) error {
    
    
    if (error) {
        
        [self _handleURLSessionError:error];
        
        return;
    }
    
    
    
    // DEV
    
    BOOL simulateError = NO;
    
    if ([[SettingsManager instanceNamed:@"dev"] valueForKey:@"simulateError"]) {
        
        simulateError = [[[SettingsManager instanceNamed:@"dev"] valueForKey:@"simulateError"] boolValue];
    }
    
    
    //---
    
    
    
    
    
    NSError* jsonError;
    
//    NSDictionary* responseDataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSDictionary* responseDataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    
    // what apple uses in https://developer.apple.com/library/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1
    
    
    
    // DEV
    
    if (simulateError) {
    
        jsonError = [NSError errorWithDomain:@"dummy" code:-1 userInfo:nil];
    }
    
    //---

    
    
    
    
    if (jsonError) {
        
        [self _handleJSONFromValidationResponseDataError:jsonError];
        
        return;
    }
    
    
    
    // 0. Handle status code
    
    NSInteger status = [responseDataDict[@"status"] integerValue];
    
    if (status != 0) {
        
        if (status == 21000  // could not read request json
            || status == 21002  // receipt data malformed
            || status == 21003  // receipt not authenticated
            || status == 21004  // shared secret invalid
            || status == 21005  // receipt server inavailable
            || status == 21007  // wrong validation server used (buy, should be sandbox)
            || status == 21008) {  // wrong validation server used (sandbox, should be buy)
            
            [self _handleResponseStatusErrorWithCode:status];
            
            return;
        }
    }
    
    
    
    
    // 1. find latest receipt info
    
    NSArray* latestReceiptInfo = responseDataDict[@"latest_receipt_info"];
    
    if (!latestReceiptInfo) {
        
        [self _handleNoLatestReceiptInfo];
        
        return;
    }
    
    
    // 2. find expiration date in most recent receipt info
    
    NSDictionary* mostRecentReceiptInfo = latestReceiptInfo.lastObject;
    NSString* expirationDateString = mostRecentReceiptInfo[@"expires_date"];
    
    if (mostRecentReceiptInfo && !expirationDateString) {
        
        [self _handleNoExpirationDateInInfo];
        
        return;
    }
    
    
    // 3. if expiration date exists transform it into a date object
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss VV";
    
    NSDate* currentExpirationDate = [formatter dateFromString:expirationDateString];
    
    if (!currentExpirationDate) {
        
        [self _handleExpirationDateFormatError];
        
        return;
    }
    
    
    
    NSString* productID = mostRecentReceiptInfo[@"product_id"];
    
    _requestCompletionBlock(currentExpirationDate, productID, nil);
}


//- (void) URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
//    
//    if (error) {
//        
//        [self _handleReceiptValidationURLSessionError:error];
//    }
//}
//
//
//
//- (void) URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
//    
//    if (error) {
//        
//        [self _handleReceiptValidationURLSessionError:error];
//    }
//}




#pragma mark - SKRequestDelegate

- (void) requestDidFinish:(SKRequest *)request {

    _refreshingReceipt = NO;

    BOOL receiptExists = [self _receiptExists];
    
    if (!receiptExists) {
        
        [self _handleNoReceiptAfterRefreshRequest];
    }
    else {
        
        [self _sendReceiptValidationRequest];
    }
}


- (void) request:(SKRequest *)request didFailWithError:(NSError *)error {

    _refreshingReceipt = NO;

    _requestCompletionBlock(nil, nil, error);
}




#pragma mark - Receipt

- (NSURL*) _receiptURL {
    
    NSURL* receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    
    return receiptURL;
}


- (BOOL) _receiptExists {
    
    return [[NSFileManager defaultManager] fileExistsAtPath:[self _receiptURL].path];
}


- (NSData*) _receiptData {
    
    NSURL* receiptURL = [self _receiptURL];
    
    if (!receiptURL) return nil;
    
    NSData* receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    return receiptData;
}




#pragma mark - Error handling

- (void) _handleNoInternet {
    
    NSError* error = [self _errorWithCode:kSubscriptionReceiptManagerErrorNoInternet];
    
    [self _reportError:error];
}


- (void) _handleURLSessionError:(NSError*) error {
    
    [self _handleReceiptValidationURLSessionError:error];
}


- (void) _handleJSONFromValidationResponseDataError:(NSError*) error {
    
    NSError* error2 = [self _errorWithCode:kSubscriptionReceiptManagerErrorJSONFromValidationResponseData];
    
    [self _reportError:error2];
}


- (void) _handleReceiptValidationURLSessionError:(NSError*) error {
    
    NSError* error2 = [self _errorWithCode:kSubscriptionReceiptManagerErrorValidationRequestURLSessionFailed];
    
    [self _reportError:error2];
}


- (void) _handleNoReceiptAfterRefreshRequest {
    
    NSError* error = [self _errorWithCode:kSubscriptionReceiptManagerErrorNoReceiptAfterRefreshRequest];
    
    [self _reportError:error];
}


- (void) _handleNoLatestReceiptInfo {
    
    NSError* error = [self _errorWithCode:kSubscriptionReceiptManagerErrorNoLatestReceiptInfo];
    
    [self _reportError:error];
}


- (void) _handleNoExpirationDateInInfo {
    
    NSError* error = [self _errorWithCode:kSubscriptionReceiptManagerErrorNoExpirationDate];
    
    [self _reportError:error];
}


- (void) _handleExpirationDateFormatError {
    
    NSError* error = [self _errorWithCode:kSubscriptionReceiptManagerErrorExpirationDateFormatError];
    
    [self _reportError:error];
}


- (void) _handleResponseStatusErrorWithCode:(NSInteger) statusCode {
    
    // map apple's code to own code (range 21000 - 210xx --> 350 - 3xx)
    
    NSInteger errorCode = statusCode - 21000 + 350;  // 21002 - 21000 = 2 + 350 = 352
    
    NSError* error = [self _errorWithCode:errorCode];
    
    [self _reportError:error];
}


- (NSError*) _errorWithCode:(NSInteger) code {
    
    NSError* error = [NSError errorWithDomain:kSubscriptionReceiptManagerErrorDomain
                                         code:code
                                     userInfo:nil];
    
    return error;
}


- (void) _reportError:(NSError*) error {

    _requestCompletionBlock(nil, nil, error);
}



@end





