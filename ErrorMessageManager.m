//
//  ErrorMessageManager.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 31.05.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ErrorMessageManager.h"
#import "CustomAlertViewController.h"
#import "CustomAlertMessageView.h"

// error domains/codes
#import "SubscriptionManager.h"
#import "SubscriptionReceiptManager.h"
#import "DownloadManager.h"
#import "HelpViewController.h"
#import "InviteFriendsHandler.h"


@implementation ErrorMessageManager



#pragma mark - Init

+ (instancetype)  instance {
    
    static id __instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __instance = [[self alloc] init];
    });
    
    return __instance;
}




- (void) handleError:(NSError*) error withParentViewController:(UIViewController*) controller completionBlock:(void(^)()) completionBlock {
    
//    _completionBlock = completionBlock;
//    _parentViewController = controller;
    
    
    NSString* errorDomain = error.domain;
    
    
    if ([errorDomain isEqualToString:kSubscriptionManagerErrorDomain]) {
        
        [self _handleSubscriptionManagerError:error parentViewController:controller completionBlock:completionBlock];
    }
    else if ([errorDomain isEqualToString:kSubscriptionReceiptManagerErrorDomain]) {
        
        [self _handleSubscriptionReceiptManagerError:error parentViewController:controller completionBlock:completionBlock];
    }
    else if ([errorDomain isEqualToString:kDownloadManagerErrorDomain]) {
        
        [self _handleDownloadManagerError:error parentViewController:controller completionBlock:completionBlock];
    }
    else if ([errorDomain isEqualToString:kHelpViewControllerErrorDomain]) {
        
        [self _handleHelpViewControllerError:error parentViewController:controller completionBlock:completionBlock];
    }
    else if ([errorDomain isEqualToString:kInviteFriendsHandlerErrorDomain]) {
        
        [self _handleInviteFriendsHandlerError:error parentViewController:controller completionBlock:completionBlock];
    }

    
}




#pragma mark - Handle Domain specific errors

// SUBSCRIPTION MANAGER

- (void) _handleSubscriptionManagerError:(NSError*) error parentViewController:(UIViewController*) controller completionBlock:(void(^)()) completionBlock {
    
    NSInteger errorCode = error.code;
    
    NSString* title = nil;
    NSString* message = nil;
    
    if (errorCode == kSubscriptionManagerErrorNoInternet) {
        
        title =     @"Keine Internetverbindung";
        message =   @"Leider konnte keine Verbindung zum Internet hergestellt werden. Bitte überprüfe Deine Einstellungen.";
    }
    
    
    
    [self showErrorPopupWithTitle:title message:message parentViewController:controller completionBlock:completionBlock];
}


// SUBSCRIPTION RECEIPT MANAGER

//NSInteger const kSubscriptionReceiptManagerErrorNoInternet = 301;
//NSInteger const kSubscriptionReceiptManagerErrorJSONFromValidationResponseData = 302;
//NSInteger const kSubscriptionReceiptManagerErrorValidationRequestURLSessionFailed = 303;
//NSInteger const kSubscriptionReceiptManagerErrorNoReceiptAfterRefreshRequest = 304;
//extern NSInteger const kSubscriptionReceiptManagerErrorNoLatestReceiptInfo;
//
//extern NSInteger const kSubscriptionReceiptManagerErrorNoExpirationDate;
//
//extern NSInteger const kSubscriptionReceiptManagerErrorExpirationDateFormatError;


- (void) _handleSubscriptionReceiptManagerError:(NSError*) error parentViewController:(UIViewController*) controller completionBlock:(void(^)()) completionBlock {
    
    NSInteger errorCode = error.code;
    
    NSString* title = nil;
    NSString* message = nil;
    
    if (errorCode == kSubscriptionReceiptManagerErrorNoInternet) {
        
        title =     @"Keine Internetverbindung";
        message =   @"Leider konnte keine Verbindung zum Internet hergestellt werden. Bitte überprüfe Deine Einstellungen.";
    }
    else if (errorCode == kSubscriptionReceiptManagerErrorJSONFromValidationResponseData
             || kSubscriptionReceiptManagerErrorValidationRequestURLSessionFailed
             || kSubscriptionReceiptManagerErrorNoReceiptAfterRefreshRequest
             || kSubscriptionReceiptManagerErrorNoLatestReceiptInfo
             || kSubscriptionReceiptManagerErrorNoExpirationDate
             || kSubscriptionReceiptManagerErrorExpirationDateFormatError) {
        
        title =     @"Überprüfung des Abos fehlgeschlagen";
        message =   [NSString stringWithFormat:@"Leider ist ein Fehler beim Überprüfen Deines Abonnements aufgetreten. Sollte sich dieser Fehler wiederholen, melde Dich bitte bei unserem Support mit der Eingabe des Fehler-Codes (Code %ld). Den Support erreichst Du unter Mehr > Hilfe und Feedback.", (long)errorCode];
    }
    
    
    [self showErrorPopupWithTitle:title message:message parentViewController:controller completionBlock:completionBlock];
}



// DOWNLOAD MANAGER

- (void) _handleDownloadManagerError:(NSError*) error parentViewController:(UIViewController*) controller completionBlock:(void(^)()) completionBlock {
    
    NSInteger errorCode = error.code;
    
    NSString* title = nil;
    NSString* message = nil;
    
    if (errorCode == kDownloadManagerErrorNoInternet) {
        
        title =     @"Keine Internetverbindung";
        message =   @"Leider konnte keine Verbindung zum Internet hergestellt werden. Bitte überprüfe Deine Einstellungen.";
    }
    else if (errorCode == kDownloadManagerErrorCantConnectToServer) {
        
        title =     @"Verbindungs-Problem";
        message =   [NSString stringWithFormat:@"Leider ist ein Fehler beim Herunterladen der Lektionen aufgetreten. Sollte sich dieser Fehler wiederholen, melde Dich bitte bei unserem Support mit der Eingabe des Fehler-Codes (Code %ld). Den Support erreichst du unter Mehr > Hilfe und Feedback.", errorCode];
    }
    
    
    
    [self showErrorPopupWithTitle:title message:message parentViewController:controller completionBlock:completionBlock];
}


// HELP VIEW CONTROLLER

- (void) _handleHelpViewControllerError:(NSError*) error parentViewController:(UIViewController*) controller completionBlock:(void(^)()) completionBlock {
    
    NSInteger errorCode = error.code;
    
    NSString* title = nil;
    NSString* message = nil;
    
    if (errorCode == kHelpViewControllerErrorNoInternet) {
        
        title =     @"Keine Internetverbindung";
        message =   @"Leider konnte keine Verbindung zum Internet hergestellt werden. Bitte überprüfe Deine Einstellungen.";
    }
    else if (errorCode == kHelpViewControllerErrorCantSendMail) {
        
        title =     @"E-Mail-Fehler";
        message =   @"Leider können keine E-Mails versandt werden. Bitte überprüfe Deine E-Mail Einstellungen.";
    }
    else if (errorCode == kHelpViewControllerErrorFailedToSend) {
        
        title =     @"E-Mail-Fehler";
        message =   @"Leider ist ein Fehler beim Versenden Deiner E-Mail aufgetreten.";
    }
 
    
    
    
    [self showErrorPopupWithTitle:title message:message parentViewController:controller completionBlock:completionBlock];
}


// INVITE FRIENDS HANDLER

- (void) _handleInviteFriendsHandlerError:(NSError*) error parentViewController:(UIViewController*) controller completionBlock:(void(^)()) completionBlock {
    
    NSInteger errorCode = error.code;
    
    NSString* title = nil;
    NSString* message = nil;
    
    if (errorCode == kInviteFriendsHandlerErrorNoInternet) {
        
        title =     @"Keine Internetverbindung";
        message =   @"Leider konnte keine Verbindung zum Internet hergestellt werden. Bitte überprüfe Deine Einstellungen.";
    }
    else if (errorCode == kInviteFriendsHandlerErrorCantSendMail) {
        
        title =     @"E-Mail-Fehler";
        message =   @"Leider können keine E-Mails versandt werden. Bitte überprüfe Deine E-Mail Einstellungen.";
    }
    else if (errorCode == kInviteFriendsHandlerErrorFailedToSend) {
        
        title =     @"E-Mail-Fehler";
        message =   @"Leider ist ein Fehler beim Versenden Deiner E-Mail aufgetreten.";
    }
    
    
    
    
    [self showErrorPopupWithTitle:title message:message parentViewController:controller completionBlock:completionBlock];
}





#pragma mark - Show Popup



- (void) showErrorPopupWithTitle:(NSString*) title message:(NSString*) message parentViewController:(UIViewController*) controller completionBlock:(void(^)()) completionBlock {
    
    NSLog(@"ErrorMessageManager - showErrorPopup (parentVC: %@)", controller);
    
    if (!controller) return;
    
    
    
    if (_displayingErrorMessage) {
        
        NSLog(@"ErrorMessageManager - already displaying!");
        
        return;
    }
    
    // --------
    
    CustomAlertViewController* alertController = [[CustomAlertViewController alloc] init];
    CustomAlertMessageView* messageView = [[CustomAlertMessageView alloc] initWithTitle:title message:message];
    alertController.contentViews = @[messageView];

    __weak UIViewController* weakParentController = controller;

    messageView.okayBlock = ^() {
        
        [weakParentController dismissViewControllerAnimated:YES completion:^{
    
            NSLog(@"dismissing error popup");

            completionBlock();

            _displayingErrorMessage = NO;
//            _parentViewController = nil;
//            _completionBlock = nil;
        }];
    };

    
    _displayingErrorMessage = YES;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ;
        ;
        
        [weakParentController presentViewController:alertController animated:YES completion:^{
        
            NSLog(@"presenting error popup");
        }];
    });
}


@end
